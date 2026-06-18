resource "azurerm_federated_identity_credential" "deploy" {
  name                = var.name
  resource_group_name = var.resource_group_name
  parent_id           = var.parent_identity_id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = var.subject
}
