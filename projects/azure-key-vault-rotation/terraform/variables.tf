# variables.tf

variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "alert_email" {
  type = string
}

variable "dry_run_rotation" {
  type        = bool
  default     = true
  description = "If true, simulate rotation without actually creating new key versions"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription id to target for resource creation"
}

variable "naming_suffix" {
  type        = string
  description = "Suffix to append to resource names for uniqueness"
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

variable "purge_protection_enabled" {
  type        = bool
  default     = false
  description = "Enable purge protection for the Key Vault (recommended for production)"
}