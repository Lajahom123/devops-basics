locals {
  name_prefix = var.project_name
  key_vault_name = var.key_vault_name != null ? var.key_vault_name : substr(
    replace(lower("kv-devops-tracker-swn"), "/[^a-z0-9-]/", ""),
    0,
    24
  )
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
