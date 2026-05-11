resource "azurerm_user_assigned_identity" "web_app" {
  name                = "id-${local.name_prefix}-webapp"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
}
