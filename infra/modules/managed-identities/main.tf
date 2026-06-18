resource "azurerm_user_assigned_identity" "main" {
  for_each = var.identities

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
