resource "azurerm_network_security_group" "main" {
  for_each = var.network_security_groups

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = {
    for key, nsg in var.network_security_groups : key => nsg
    if nsg.subnet_id != null
  }

  subnet_id                 = each.value.subnet_id
  network_security_group_id = azurerm_network_security_group.main[each.key].id
}
