terraform {
  backend "azurerm" {
    resource_group_name  = "rg-state"
    storage_account_name = "tfbackendkt"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}