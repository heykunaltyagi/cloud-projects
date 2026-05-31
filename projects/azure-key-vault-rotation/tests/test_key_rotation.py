# tests/test_key_rotation.py

import pytest
from unittest.mock import Mock, patch
import json
from datetime import datetime
from KeyRotationTrigger import KeyRotationEngine


@pytest.fixture
def engine():
    with patch.dict('os.environ', {
        'KEY_VAULT_NAME': 'test-kv',
        'EVENT_HUB_CONNECTION_STRING': 'test-conn',
        'EVENT_HUB_NAME': 'test-hub',
        'COSMOS_DB_CONNECTION_STRING': 'test-cosmos',
        'COSMOS_DB_DATABASE': 'test-db',
        'COSMOS_DB_CONTAINER': 'test-container',
        'DRY_RUN': 'true'
    }):
        with patch('KeyRotationTrigger.KeyClient'):
            with patch('KeyRotationTrigger.EventHubProducerClient'):
                with patch('KeyRotationTrigger.CosmosClient'):
                    yield KeyRotationEngine()


def test_should_rotate_respects_disabled_tag(engine):
    """Verify keys with rotation_enabled=false are skipped"""
    
    # Mock key with rotation disabled
    mock_key = Mock()
    mock_key.properties.tags = {'rotation_enabled': 'false'}
    
    with patch.object(engine.key_client, 'get_key', return_value=mock_key):
        assert engine._should_rotate('test-key') == False


def test_should_rotate_prevents_thrashing(engine):
    """Verify keys aren't rotated more than once per day"""
    
    with patch.object(engine, '_was_recently_rotated', return_value=True):
        assert engine._should_rotate('test-key') == False


def test_rotation_creates_new_version(engine):
    """Verify new key version is created"""
    
    mock_old_key = Mock()
    mock_old_key.key_type = 'RSA'
    mock_old_key.key_size = 2048
    mock_old_key.key_operations = ['encrypt', 'decrypt']
    mock_old_key.properties.tags = {}
    
    mock_new_key = Mock()
    mock_new_key.properties.version = 'new-version-123'
    
    with patch.object(engine.key_client, 'get_key', return_value=mock_old_key):
        with patch.object(engine.key_client, 'create_key', return_value=mock_new_key):
            result = engine._create_new_key_version('test-key')
            assert result.properties.version == 'new-version-123'


def test_dry_run_prevents_actual_rotation(engine):
    """Verify dry-run mode doesn't create actual keys"""
    
    engine.dry_run = True
    mock_key = Mock()
    mock_key.properties.version = 'original'
    
    with patch.object(engine.key_client, 'get_key', return_value=mock_key):
        result = engine._create_new_key_version('test-key')
        # Should return original key without calling create_key
        engine.key_client.create_key.assert_not_called()


def test_event_handler_logs_rotation_event(engine):
    """Verify rotation events are logged to Cosmos DB"""
    
    event = {
        'subject': '/subscriptions/sub123/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/mykv/keys/mykey',
        'eventType': 'Microsoft.KeyVault.KeyNearExpiry'
    }
    
    with patch.object(engine, '_should_rotate', return_value=True):
        with patch.object(engine, '_get_current_key_version'):
            with patch.object(engine, '_create_new_key_version'):
                with patch.object(engine, '_validate_and_update_dependents', return_value={'success': True}):
                    with patch.object(engine, '_log_rotation_event') as mock_log:
                        engine.handle_key_expiration_event(event)
                        mock_log.assert_called_once()