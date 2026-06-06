output "cosmos_connection_string" {
  value = azurerm_cosmosdb_account.rotation_history.primary_sql_connection_string
}

output "cosmos_database_name" {
  value = azurerm_cosmosdb_sql_database.rotation_history.name
}

output "cosmos_container_name" {
  value = azurerm_cosmosdb_sql_container.rotation_log.name
}
