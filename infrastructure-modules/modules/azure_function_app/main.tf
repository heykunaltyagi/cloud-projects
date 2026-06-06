resource "random_string" "storage_suffix" {
  length  = 6
  special = false
}

resource "random_string" "func_suffix" {
  length  = 6
  special = false
}

resource "azurerm_storage_account" "function_storage" {
  name                     = "stfuncrotation${var.environment}${random_string.storage_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_service_plan" "function_plan" {
  name                = "asp-key-rotation-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_user_assigned_identity" "function_app" {
  name                = "id-key-rotation-function-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_eventhub_namespace" "main" {
  name                = "ehn-keyrotation-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  capacity            = 1

  tags = {
    purpose = "key-rotation-audit"
  }
}

resource "azurerm_eventhub" "rotation_audit" {
  name                = "rotation-audit-log"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  partition_count     = 2
  message_retention   = 7
}

resource "azurerm_eventhub_consumer_group" "analytics" {
  name                = "analytics-consumer"
  namespace_name      = azurerm_eventhub_namespace.main.name
  eventhub_name       = azurerm_eventhub.rotation_audit.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_access_policy" "function_app" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_user_assigned_identity.function_app.tenant_id
  object_id    = azurerm_user_assigned_identity.function_app.principal_id

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Update",
    "Delete",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}

resource "azurerm_linux_function_app" "key_rotation" {
  name                       = "func-key-rotation-${var.environment}-${random_string.func_suffix.result}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  site_config {}
  functions_extension_version = "~4"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.function_app.id]
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"            = "python"
    "ENABLE_MSBUILD"                      = "true"
    "KEY_VAULT_NAME"                      = var.key_vault_name
    "EVENT_HUB_CONNECTION_STRING"         = azurerm_eventhub_namespace.main.default_primary_connection_string
    "EVENT_HUB_NAME"                      = azurerm_eventhub.rotation_audit.name
    # Cosmos DB removed: rotation history not stored
    "DRY_RUN"                             = tostring(var.dry_run_rotation)
    "ROTATION_VALIDATION_TIMEOUT_SECONDS" = "300"
  }

  depends_on = [
    azurerm_key_vault_access_policy.function_app
  ]
}
