terraform {
  backend "azurerm" {
    resource_group_name  = "rg-devops-tracker-dev-tfstate"
    storage_account_name = "stdevopstrackerswedenct"
    container_name       = "full-infra"
    key                  = "foundation.tfstate"
  }
}
