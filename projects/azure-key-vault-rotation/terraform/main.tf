resource "azurerm_resource_group" "main" {
  name     = "rg-key-rotation-${var.environment}"
  location = var.azure_region
}

module "key_vault" {
  source              = "../../../infrastructure-modules/modules/azure_key_vault"
  environment         = var.environment
  azure_region        = var.azure_region
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

module "function_app" {
  source                      = "../../../infrastructure-modules/modules/azure_function_app"
  environment                 = var.environment
  azure_region                = var.azure_region
  resource_group_name         = azurerm_resource_group.main.name
  location                    = azurerm_resource_group.main.location
  key_vault_id                = module.key_vault.key_vault_id
  key_vault_name              = module.key_vault.key_vault_name
  dry_run_rotation            = var.dry_run_rotation
}

module "event_grid" {
  source                        = "../../../infrastructure-modules/modules/azure_event_grid"
  environment                   = var.environment
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
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
