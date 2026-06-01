resource "azurerm_bastion_host" "main" {
  name                = "bas-devops-tracker"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.location
  tags                = local.common_tags

  sku = "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-devops-tracker"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.location
  tags                = local.common_tags

  allocation_method = "Static"
  sku               = "Standard"
}