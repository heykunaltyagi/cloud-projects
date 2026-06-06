variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "key_vault_name" {
  type = string
}
variable "dry_run_rotation" {
  type = bool
}

variable "storage_account_replication_type" {
  type    = string
  default = "LRS"
}

variable "service_plan_os_type" {
  type    = string
  default = "Linux"
}

variable "service_plan_sku_name" {
  type    = string
  default = "Y1"
}

variable "eventhub_sku" {
  type    = string
  default = "Standard"
}

variable "eventhub_capacity" {
  type    = number
  default = 1
}

variable "function_site_config" {
  type    = map(any)
  default = {}
}

variable "function_app_settings" {
  type    = map(string)
  default = {}
}

variable "naming_suffix" {
  type = string
}
