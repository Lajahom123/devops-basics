resource "azurerm_role_assignment" "aks_control_plane_network_contributor_on_aks_subnet" {
  scope                = local.aks_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = local.aks_identity.principal_id
}

resource "azurerm_role_assignment" "aks_ingress_public_ip_network_contributor" {
  scope                = local.platform.ingress_public_ip_id
  role_definition_name = "Network Contributor"
  principal_id         = local.aks_identity.principal_id
}

resource "azurerm_role_assignment" "github_actions_aks_user" {
  scope                = local.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = local.platform.github_actions_deploy_principal_id
}