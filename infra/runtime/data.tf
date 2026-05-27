locals {
  name_prefix = var.project_name
  common_tags = {
    Owner = var.owner_email
  }
}

data "azurerm_client_config" "current" {}

data "terraform_remote_state" "foundation" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-devops-tracker-dev"
    storage_account_name = "stdevopstrackerswn"
    container_name       = "full-infra"
    key                  = "foundation.tfstate"
  }
}
