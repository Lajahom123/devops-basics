resource "azurerm_federated_identity_credential" "aks_workload" {
  name                = "aks-workload"
  resource_group_name = local.platform_resource_group_name
  parent_id           = local.aks_workload_identity.id

  audience = ["api://AzureADTokenExchange"]
  issuer   = local.aks_oidc_issuer_url
  subject  = "system:serviceaccount:devops-tracker:devops-tracker-api"
}

resource "azurerm_federated_identity_credential" "postgres_bootstrap" {
  name                = "postgres-entra-bootstrap"
  resource_group_name = local.platform_resource_group_name
  parent_id           = local.postgres_bootstrap_identity.id

  audience = ["api://AzureADTokenExchange"]
  issuer   = local.aks_oidc_issuer_url
  subject  = "system:serviceaccount:devops-tracker:postgres-entra-bootstrap"
}