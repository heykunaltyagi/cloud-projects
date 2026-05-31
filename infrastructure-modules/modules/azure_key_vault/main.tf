resource "random_string" "kv_suffix" {
  length  = 6
  special = false
}

resource "azurerm_key_vault" "main" {
  name                            = "kv-rotation-${var.environment}-${random_string.kv_suffix.result}"
  location                        = var.azure_region
  resource_group_name             = var.resource_group_name
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  tenant_id                       = var.tenant_id
  sku_name                        = "standard"
  soft_delete_retention_days      = 90
  purge_protection_enabled        = var.environment == "prod" ? true : false
}

resource "azurerm_key_vault_key" "app_encryption_key" {
  name            = "app-encryption-key"
  key_vault_id    = azurerm_key_vault.main.id
  key_type        = "RSA"
  key_size        = 2048
  expiration_date = timeadd(timestamp(), "720h")

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  tags = {
    rotation_policy = "automatic"
    rotation_days   = "30"
  }
}
