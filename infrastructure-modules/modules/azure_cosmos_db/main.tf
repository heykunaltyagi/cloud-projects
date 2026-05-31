resource "random_string" "cosmos_suffix" {
  length  = 6
  special = false
}

resource "azurerm_cosmosdb_account" "rotation_history" {
  name                = "cosmos-rotation-${var.environment}-${random_string.cosmos_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "rotation_history" {
  name                = "rotation-database"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.rotation_history.name
}

resource "azurerm_cosmosdb_sql_container" "rotation_log" {
  name                = "rotation-log"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.rotation_history.name
  database_name       = azurerm_cosmosdb_sql_database.rotation_history.name
  partition_key_paths = ["/key_vault_name"]
  default_ttl         = 7776000
}
