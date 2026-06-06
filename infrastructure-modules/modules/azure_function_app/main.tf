resource "azurerm_storage_account" "function_storage" {
  name                     = "stfuncrotation${var.environment}${var.naming_suffix}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication_type
  account_kind             = "StorageV2"
}

resource "azurerm_service_plan" "function_plan" {
  name                = "asp-key-rotation-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.service_plan_os_type
  sku_name            = var.service_plan_sku_name
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
  sku                 = var.eventhub_sku
  capacity            = var.eventhub_capacity

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

locals {
  default_app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"            = "python"
    "ENABLE_MSBUILD"                      = "true"
    "KEY_VAULT_NAME"                      = var.key_vault_name
    "EVENT_HUB_CONNECTION_STRING"         = azurerm_eventhub_namespace.main.default_primary_connection_string
    "EVENT_HUB_NAME"                      = azurerm_eventhub.rotation_audit.name
    "DRY_RUN"                             = tostring(var.dry_run_rotation)
    "ROTATION_VALIDATION_TIMEOUT_SECONDS" = "300"
  }
}

resource "azurerm_linux_function_app" "key_rotation" {
  name                       = "func-key-rotation-${var.environment}-${var.naming_suffix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  site_config {
    always_on          = lookup(var.function_site_config, "always_on", null)
    http2_enabled      = lookup(var.function_site_config, "http2_enabled", null)
    websockets_enabled = lookup(var.function_site_config, "websockets_enabled", null)
  }
  functions_extension_version = lookup(var.function_site_config, "functions_extension_version", "~4")

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.function_app.id]
  }

  app_settings = merge(local.default_app_settings, var.function_app_settings)

  depends_on = [
    azurerm_key_vault_access_policy.function_app
  ]
}
