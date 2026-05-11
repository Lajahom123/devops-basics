data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "foundation" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "foundation" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.foundation.name
}

data "azurerm_subnet" "app_service" {
  name                 = var.app_service_subnet_name
  resource_group_name  = data.azurerm_resource_group.foundation.name
  virtual_network_name = data.azurerm_virtual_network.foundation.name
}

data "azurerm_subnet" "postgres" {
  name                 = var.postgres_subnet_name
  resource_group_name  = data.azurerm_resource_group.foundation.name
  virtual_network_name = data.azurerm_virtual_network.foundation.name
}

data "azurerm_private_dns_zone" "postgres" {
  name                = var.postgres_private_dns_zone_name
  resource_group_name = data.azurerm_resource_group.foundation.name
}

data "azurerm_user_assigned_identity" "web_app" {
  name                = var.web_app_identity_name
  resource_group_name = data.azurerm_resource_group.foundation.name
}
