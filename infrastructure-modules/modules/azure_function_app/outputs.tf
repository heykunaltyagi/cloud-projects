output "function_id" {
  value = azurerm_function_app.key_rotation.id
}

output "function_app_principal_id" {
  value = azurerm_user_assigned_identity.function_app.principal_id
}

output "storage_account_id" {
  value = azurerm_storage_account.function_storage.id
}

output "eventhub_id" {
  value = azurerm_eventhub.rotation_audit.id
}

output "eventhub_name" {
  value = azurerm_eventhub.rotation_audit.name
}

output "eventhub_connection_string" {
  value = azurerm_eventhub_namespace.main.default_primary_connection_string
}

output "storage_account_name" {
  value = azurerm_storage_account.function_storage.name
}
