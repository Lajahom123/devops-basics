terraform {
  backend "azurerm" {
    resource_group_name  = "rg-devops-tracker-dev"
    storage_account_name = "stdevopstrackerswn"
    container_name       = "full-infra"
    key                  = "runtime.tfstate"
  }
}