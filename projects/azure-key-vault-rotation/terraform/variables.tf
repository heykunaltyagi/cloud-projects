# variables.tf

variable "environment" {
  type    = string
  default = "dev"
}

variable "azure_region" {
  type    = string
  default = "eastus"
}

variable "slack_webhook_url" {
  type      = string
  sensitive = true
}

variable "alert_email" {
  type = string
}

variable "dry_run_rotation" {
  type        = bool
  default     = true
  description = "If true, simulate rotation without actually creating new key versions"
}