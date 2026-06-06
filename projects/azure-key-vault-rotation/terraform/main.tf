resource "azurerm_resource_group" "main" {
  name     = "rg-key-rotation-${var.environment}"
  location = var.location
}

module "key_vault" {
  source                   = "../../../infrastructure-modules/modules/azure_key_vault"
  environment              = var.environment
  location                 = var.location
  resource_group_name      = azurerm_resource_group.main.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  naming_suffix            = var.naming_suffix
  purge_protection_enabled = var.purge_protection_enabled
}

module "function_app" {
  source                           = "../../../infrastructure-modules/modules/azure_function_app"
  environment                      = var.environment
  location                         = var.location
  resource_group_name              = azurerm_resource_group.main.name
  key_vault_id                     = module.key_vault.key_vault_id
  key_vault_name                   = module.key_vault.key_vault_name
  dry_run_rotation                 = var.dry_run_rotation
  naming_suffix                    = var.naming_suffix
  storage_account_replication_type = var.storage_account_replication_type
  service_plan_os_type             = var.service_plan_os_type
  service_plan_sku_name            = var.service_plan_sku_name
  eventhub_sku                     = var.eventhub_sku
  eventhub_capacity                = var.eventhub_capacity
  function_site_config             = var.function_site_config
  function_app_settings            = var.function_app_settings
}

module "event_grid" {
  source                        = "../../../infrastructure-modules/modules/azure_event_grid"
  environment                   = var.environment
  resource_group_name           = azurerm_resource_group.main.name
  location                      = var.location
  key_vault_id                  = module.key_vault.key_vault_id
  function_app_function_id      = module.function_app.function_id
  function_storage_account_id   = module.function_app.storage_account_id
  function_storage_account_name = module.function_app.storage_account_name
  eventhub_id                   = module.function_app.eventhub_id
}

module "monitoring" {
  source              = "../../../infrastructure-modules/modules/azure_monitoring"
  environment         = var.environment
  resource_group_name = azurerm_resource_group.main.name
  alert_email         = var.alert_email
  function_id         = module.function_app.function_id
}
