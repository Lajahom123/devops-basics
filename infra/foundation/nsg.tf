resource "azurerm_network_security_group" "github_runner" {
  name                = "nsg-github-runner"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "github_runner" {
  subnet_id                 = azurerm_subnet.github_runner.id
  network_security_group_id = azurerm_network_security_group.github_runner.id
}