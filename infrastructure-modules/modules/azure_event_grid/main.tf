resource "azurerm_eventgrid_system_topic" "key_vault_topic" {
  name                   = "eg-keyvault-events-${var.environment}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  source_arm_resource_id = var.key_vault_id
  topic_type             = "Microsoft.KeyVault.vaults"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "rotation_function" {
  name                = "sub-rotation-function"
  system_topic        = azurerm_eventgrid_system_topic.key_vault_topic.name
  resource_group_name = var.resource_group_name

  advanced_filter {
    string_in {
      key    = "eventType"
      values = ["Microsoft.KeyVault.KeyNearExpiry"]
    }
  }

  azure_function_endpoint {
    function_id = "${var.function_app_function_id}/functions/KeyRotationTrigger"
  }

  retry_policy {
    event_time_to_live    = 1440
    max_delivery_attempts = 3
  }
}

resource "azurerm_storage_container" "eventgrid_dead_letter" {
  name                  = "eventgrid-deadletter"
  storage_account_name  = var.function_storage_account_name
  container_access_type = "private"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "audit_hub" {
  name                = "sub-audit-hub"
  system_topic        = azurerm_eventgrid_system_topic.key_vault_topic.name
  resource_group_name = var.resource_group_name

  advanced_filter {
    string_in {
      key = "eventType"
      values = [
        "Microsoft.KeyVault.KeyNearExpiry",
        "Microsoft.KeyVault.KeyCreated",
        "Microsoft.KeyVault.KeyUpdated",
        "Microsoft.KeyVault.KeyDeleted"
      ]
    }
  }

  eventhub_endpoint_id = var.eventhub_id

  storage_blob_dead_letter_destination {
    storage_account_id          = var.function_storage_account_id
    storage_blob_container_name = azurerm_storage_container.eventgrid_dead_letter.name
  }
}
