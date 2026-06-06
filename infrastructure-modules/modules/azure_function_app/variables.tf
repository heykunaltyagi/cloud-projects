variable "environment" {
  type = string
}

variable "azure_region" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "cosmos_db_connection_string" {
  type = string
}

variable "cosmos_db_database_name" {
  type = string
}

variable "cosmos_db_container_name" {
  type = string
}

variable "dry_run_rotation" {
  type = bool
}
