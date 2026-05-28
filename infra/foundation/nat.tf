resource "azurerm_public_ip" "nat" {
  name                = "pip-nat-${local.name_prefix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.common_tags

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_nat_gateway" "main" {
  name                = "nat-${local.name_prefix}n"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.common_tags

  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
}


# Associations

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "github_runner" {
  subnet_id      = azurerm_subnet.github_runner.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

resource "azurerm_subnet_nat_gateway_association" "aks_nodes" {
  subnet_id      = azurerm_subnet.aks_nodes.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}