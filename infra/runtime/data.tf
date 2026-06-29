locals {
  name_prefix = var.project_name
  common_tags = {
    Owner = var.owner_email
  }
}

data "azurerm_client_config" "current" {}

data "terraform_remote_state" "platform" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-devops-tracker-dev"
    storage_account_name = "stdevopstrackerswedenct"
    container_name       = "full-infra"
    key                  = "platform.tfstate"
  }
}
