resource "azurerm_role_definition" "aks_deployment_executor" {
  name        = "AKS Deployment Executor"
  scope       = azurerm_kubernetes_cluster.main.id
  description = "Allows GitHub Actions to get AKS user credentials for deployment."

  permissions {
    actions = [
      "Microsoft.ContainerService/managedClusters/read",
      "Microsoft.ContainerService/managedClusters/listClusterUserCredential/action"
    ]

    not_actions      = []
    data_actions     = []
    not_data_actions = []
  }

  assignable_scopes = [
    azurerm_kubernetes_cluster.main.id
  ]
}

resource "azurerm_role_assignment" "github_actions_aks_deployment_executor" {
  scope              = azurerm_kubernetes_cluster.main.id
  role_definition_id = azurerm_role_definition.aks_deployment_executor.role_definition_resource_id
  principal_id       = data.terraform_remote_state.foundation.outputs.github_actions_deploy_principal_id
}