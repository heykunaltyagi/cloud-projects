# KeyRotationTrigger/__init__.py

import azure.functions as func
import json
import logging
from datetime import datetime, timedelta
from azure.identity import DefaultAzureCredential
from azure.keyvault.keys import KeyClient
from azure.eventhub import EventHubProducerClient
from azure.cosmos import CosmosClient, exceptions
import requests
import os

logger = logging.getLogger(__name__)


class KeyRotationEngine:
    """Handles Key Vault key rotation with validation & rollback"""
    
    def __init__(self):
        self.key_vault_name = os.environ['KEY_VAULT_NAME']
        self.key_vault_url = f"https://{self.key_vault_name}.vault.azure.net/"
        self.dry_run = os.environ.get('DRY_RUN', 'false').lower() == 'true'
        
        # Clients
        credential = DefaultAzureCredential()
        self.key_client = KeyClient(vault_url=self.key_vault_url, credential=credential)
        self.eh_client = EventHubProducerClient.from_connection_string(
            os.environ['EVENT_HUB_CONNECTION_STRING'],
            eventhub_name=os.environ['EVENT_HUB_NAME']
        )
        
        cosmos_client = CosmosClient.from_connection_string(
            os.environ['COSMOS_DB_CONNECTION_STRING']
        )
        self.db_client = cosmos_client.get_database_client(
            os.environ['COSMOS_DB_DATABASE']
        )
        self.rotation_container = self.db_client.get_container_client(
            os.environ['COSMOS_DB_CONTAINER']
        )
    
    def handle_key_expiration_event(self, event: dict) -> dict:
        """Main entry point: triggered by Event Grid when key near expiry"""
        
        try:
            logger.info(f"Received Key Vault event: {json.dumps(event)}")
            
            # Parse event
            key_name = event['subject'].split('/')[-1]
            key_vault_name = event['subject'].split('/')[2].split('.')[0]
            
            logger.info(f"Processing key rotation for: {key_name}")
            
            # Step 1: Validate rotation is safe
            if not self._should_rotate(key_name):
                logger.warning(f"Skipping rotation for {key_name}: safety check failed")
                return {'status': 'skipped', 'reason': 'safety check'}
            
            # Step 2: Rotate the key
            old_version = self._get_current_key_version(key_name)
            new_key = self._create_new_key_version(key_name)
            
            # Step 3: Update dependent services
            validation_result = self._validate_and_update_dependents(key_name, new_key)
            
            if not validation_result['success']:
                logger.error(f"Validation failed, rolling back")
                self._rollback_key_version(key_name, old_version)
                raise Exception(f"Validation failed: {validation_result['error']}")
            
            # Step 4: Log rotation to history
            self._log_rotation_event(key_name, old_version, new_key, 'success')
            
            # Step 5: Notify
            self._notify_slack(key_name, new_key, 'success')
            self._send_audit_event(key_name, 'rotation_completed', new_key)
            
            return {
                'status': 'success',
                'key_name': key_name,
                'new_version': new_key.properties.version,
                'old_version': old_version.properties.version
            }
        
        except Exception as e:
            logger.error(f"Key rotation failed: {str(e)}", exc_info=True)
            self._notify_slack(key_name, None, 'failed', error=str(e))
            raise
    
    def _should_rotate(self, key_name: str) -> bool:
        """Validate that rotation is safe"""
        
        try:
            # Get key properties
            key = self.key_client.get_key(key_name)
            
            # Check 1: Is rotation disabled?
            if key.properties.tags and key.properties.tags.get('rotation_enabled') == 'false':
                logger.info(f"{key_name} has rotation disabled")
                return False
            
            # Check 2: Was it recently rotated? (prevent thrashing)
            if self._was_recently_rotated(key_name):
                logger.warning(f"{key_name} was recently rotated, skipping")
                return False
            
            # Check 3: Check for active maintenance windows
            if key.properties.tags and key.properties.tags.get('maintenance') == 'active':
                logger.info(f"{key_name} in maintenance window")
                return False
            
            return True
        
        except Exception as e:
            logger.error(f"Error validating rotation for {key_name}: {str(e)}")
            return False
    
    def _was_recently_rotated(self, key_name: str, hours: int = 24) -> bool:
        """Check if key was rotated in last N hours"""
        try:
            query = f"""
                SELECT * FROM c 
                WHERE c.key_name = @key_name 
                AND c.action = 'rotation_completed'
                AND c.timestamp > DateTimeAdd('hour', -{hours}, GetCurrentTimestamp())
                ORDER BY c.timestamp DESC
                LIMIT 1
            """
            
            items = list(self.rotation_container.query_items(
                query=query,
                parameters=[{'name': '@key_name', 'value': key_name}]
            ))
            
            return len(items) > 0
        except Exception as e:
            logger.warning(f"Could not check rotation history: {str(e)}")
            return False
    
    def _get_current_key_version(self, key_name: str):
        """Get the current active version of a key"""
        return self.key_client.get_key(key_name)
    
    def _create_new_key_version(self, key_name: str):
        """Create a new version of the key"""
        
        current_key = self.key_client.get_key(key_name)
        
        if self.dry_run:
            logger.info(f"[DRY RUN] Would create new version of {key_name}")
            return current_key
        
        logger.info(f"Creating new version of {key_name}")
        
        # Create new key with same properties as old one
        new_key = self.key_client.create_key(
            name=key_name,
            key_type=current_key.key_type,
            key_size=current_key.key_size,
            key_operations=current_key.key_operations,
            expires_on=datetime.utcnow() + timedelta(days=365),
            tags=current_key.properties.tags or {}
        )
        
        logger.info(f"Created new key version: {new_key.properties.version}")
        return new_key
    
    def _validate_and_update_dependents(self, key_name: str, new_key) -> dict:
        """
        Update services that use this key and validate they still work.
        This is where you'd update your app configs, databases, etc.
        """
        
        try:
            logger.info(f"Validating and updating dependents for {key_name}")
            
            # Example 1: Update app configuration
            if key_name == 'app-encryption-key':
                result = self._update_app_config(key_name, new_key)
                if not result['success']:
                    return result
            
            # Example 2: Update database encryption
            if key_name == 'db-encryption-key':
                result = self._update_db_encryption(key_name, new_key)
                if not result['success']:
                    return result
            
            # Example 3: Validate services can read new key
            if not self._health_check_services(key_name):
                return {'success': False, 'error': 'Service health check failed'}
            
            return {'success': True}
        
        except Exception as e:
            logger.error(f"Validation failed: {str(e)}")
            return {'success': False, 'error': str(e)}
    
    def _update_app_config(self, key_name: str, new_key) -> dict:
        """Update app configuration with new key version"""
        
        if self.dry_run:
            logger.info(f"[DRY RUN] Would update app config with new key version")
            return {'success': True}
        
        try:
            # Example: Update Azure App Configuration
            # In reality, you'd call Azure AppConfig API or Kubernetes secret
            logger.info(f"Updating app configuration with key {new_key.properties.version}")
            
            # Pseudo-code:
            # app_config_client.set_configuration_setting(
            #     key=f"{key_name}_version",
            #     value=new_key.properties.version
            # )
            
            return {'success': True}
        
        except Exception as e:
            return {'success': False, 'error': str(e)}
    
    def _update_db_encryption(self, key_name: str, new_key) -> dict:
        """Update database encryption key"""
        
        if self.dry_run:
            logger.info(f"[DRY RUN] Would update DB encryption with new key")
            return {'success': True}
        
        try:
            logger.info(f"Updating database encryption with key {new_key.properties.version}")
            
            # Pseudo-code:
            # sql_client.set_transparent_data_encryption_key(new_key.id)
            
            return {'success': True}
        
        except Exception as e:
            return {'success': False, 'error': str(e)}
    
    def _health_check_services(self, key_name: str, timeout: int = None) -> bool:
        """Verify that services can access and use the new key"""
        
        timeout = timeout or int(os.environ.get('ROTATION_VALIDATION_TIMEOUT_SECONDS', '300'))
        
        try:
            logger.info(f"Running health checks for services using {key_name}")
            
            # Example: Call your service health check endpoint
            # that verifies it can decrypt/encrypt with the new key
            
            # In real scenario:
            # response = requests.get(
            #     'https://myapp.com/health/key-validation',
            #     params={'key': key_name},
            #     timeout=timeout
            # )
            # return response.status_code == 200
            
            return True
        
        except Exception as e:
            logger.error(f"Health check failed: {str(e)}")
            return False
    
    def _rollback_key_version(self, key_name: str, old_key):
        """Rollback to previous key version if rotation failed"""
        
        if self.dry_run:
            logger.info(f"[DRY RUN] Would rollback {key_name} to version {old_key.properties.version}")
            return
        
        logger.warning(f"Rolling back {key_name} to previous version")
        
        try:
            # Update services back to old key version
            self._update_app_config(key_name, old_key)
            self._update_db_encryption(key_name, old_key)
            
            logger.info(f"Rollback completed for {key_name}")
        
        except Exception as e:
            logger.error(f"Rollback failed: {str(e)}")
            raise
    
    def _log_rotation_event(self, key_name: str, old_version, new_version, status: str):
        """Store rotation event in Cosmos DB"""
        
        try:
            doc = {
                'id': f"{key_name}-{datetime.utcnow().isoformat()}",
                'key_name': key_name,
                'key_vault_name': self.key_vault_name,
                'old_version': old_version.properties.version if old_version else None,
                'new_version': new_version.properties.version if new_version else None,
                'status': status,
                'timestamp': datetime.utcnow().isoformat(),
                'dry_run': self.dry_run,
                'created_at': datetime.utcnow().timestamp()  # For TTL
            }
            
            self.rotation_container.create_item(doc)
            logger.info(f"Logged rotation event for {key_name}")
        
        except Exception as e:
            logger.error(f"Failed to log rotation: {str(e)}")
    
    def _send_audit_event(self, key_name: str, action: str, new_key):
        """Send audit event to Event Hub"""
        
        try:
            with self.eh_client:
                event_data = {
                    'key_name': key_name,
                    'action': action,
                    'new_version': new_key.properties.version if new_key else None,
                    'timestamp': datetime.utcnow().isoformat(),
                    'dry_run': self.dry_run
                }
                
                batch = self.eh_client.create_batch()
                batch.add(json.dumps(event_data))
                self.eh_client.send_batch(batch)
                
                logger.info(f"Sent audit event to Event Hub: {action}")
        
        except Exception as e:
            logger.error(f"Failed to send audit event: {str(e)}")
    
    def _notify_slack(self, key_name: str, new_key, status: str, error: str = None):
        """Send Slack notification"""
        
        webhook_url = os.environ.get('SLACK_WEBHOOK_URL')
        if not webhook_url:
            return
        
        color = 'danger' if status == 'failed' else 'good'
        
        message = {
            'attachments': [
                {
                    'color': color,
                    'title': f'Key Rotation: {status.upper()}',
                    'fields': [
                        {'title': 'Key Name', 'value': key_name, 'short': True},
                        {'title': 'Status', 'value': status, 'short': True},
                        {'title': 'New Version', 'value': new_key.properties.version if new_key else 'N/A', 'short': True},
                        {'title': 'Dry Run', 'value': str(self.dry_run), 'short': True},
                        {'title': 'Timestamp', 'value': datetime.utcnow().isoformat(), 'short': False},
                    ]
                }
            ]
        }
        
        if error:
            message['attachments'][0]['fields'].append({
                'title': 'Error',
                'value': error,
                'short': False
            })
        
        try:
            requests.post(webhook_url, json=message, timeout=10)
        except Exception as e:
            logger.error(f"Failed to send Slack notification: {str(e)}")


def main(req: func.HttpRequest, context: func.Context = None) -> func.HttpResponse:
    """Entry point for HTTP trigger (for testing)"""
    
    try:
        event_data = req.get_json()
        engine = KeyRotationEngine()
        result = engine.handle_key_expiration_event(event_data)
        
        return func.HttpResponse(
            json.dumps(result),
            status_code=200,
            mimetype="application/json"
        )
    except Exception as e:
        logger.error(f"Error: {str(e)}", exc_info=True)
        return func.HttpResponse(
            json.dumps({'error': str(e)}),
            status_code=500,
            mimetype="application/json"
        )


def event_grid_trigger(event: func.EventGridEvent):
    """Entry point for Event Grid trigger"""
    
    try:
        engine = KeyRotationEngine()
        
        # Parse Event Grid event
        event_data = {
            'subject': event.subject,
            'event_type': event.event_type,
            'data': event.get_json()
        }
        
        result = engine.handle_key_expiration_event(event_data)
        logger.info(f"Rotation result: {json.dumps(result)}")
        
    except Exception as e:
        logger.error(f"Event Grid trigger error: {str(e)}", exc_info=True)
        raise