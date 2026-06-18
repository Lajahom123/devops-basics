data "azurerm_client_config" "current" {}

resource "random_string" "foundation_suffix" {
  length  = 6
  upper   = false
  special = false
}

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

module "acr" {
  source = "../modules/acr"

  name                = local.acr_name
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  sku                 = "Basic"
}

module "managed_identities" {
  source = "../modules/managed-identities"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  name_prefix         = local.name_prefix
  tags                = local.common_tags
}
