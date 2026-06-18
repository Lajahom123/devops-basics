data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "platform" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source = "../modules/network"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  project             = var.project
  environment         = var.environment
  vnet_name           = local.vnet_name
  address_space       = ["10.20.0.0/16"]
  subnets             = local.subnets
  tags                = local.common_tags
}
