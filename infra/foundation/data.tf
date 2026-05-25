locals {
  name_prefix = var.project_name
  common_tags = {
    Owner = var.owner_email
  }
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}