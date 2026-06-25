resource "azurerm_role_assignment" "aks_control_plane_network_contributor_on_aks_subnet" {
  scope                = local.aks_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = local.aks_identity.principal_id
}

resource "azurerm_role_assignment" "aks_ingress_public_ip_network_contributor" {
  scope                = local.foundation.ingress_public_ip_id
  role_definition_name = "Network Contributor"
  principal_id         = local.aks_identity.principal_id
}