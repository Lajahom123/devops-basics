resource "azurerm_private_dns_zone" "main" {
  for_each = var.zones

  name                = each.value.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  for_each = var.zones

  name                  = each.value.virtual_network_link
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main[each.key].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = each.value.registration_enabled
  tags                  = var.tags
}
