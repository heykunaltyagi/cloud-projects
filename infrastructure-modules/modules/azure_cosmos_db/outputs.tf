output "cosmos_connection_string" {
  value = azurerm_cosmosdb_account.rotation_history.connection_strings[0]
}

output "cosmos_database_name" {
  value = azurerm_cosmosdb_sql_database.rotation_history.name
}

output "cosmos_container_name" {
  value = azurerm_cosmosdb_sql_container.rotation_log.name
}
