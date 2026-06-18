resource "azurerm_role_definition" "acr_build_executor" {
  name        = "DevOps Tracker ACR Build Executor"
  scope       = module.acr.acr_id
  description = "Allows GitHub Actions to run ACR remote builds and push resulting images."

  permissions {
    actions = [
      "Microsoft.ContainerRegistry/registries/read",
      "Microsoft.ContainerRegistry/registries/listBuildSourceUploadUrl/action",
      "Microsoft.ContainerRegistry/registries/scheduleRun/action",
      "Microsoft.ContainerRegistry/registries/runs/read",
      "Microsoft.ContainerRegistry/registries/runs/listLogSasUrl/action",
    ]

    data_actions = [
      "Microsoft.ContainerRegistry/registries/repositories/content/read",
      "Microsoft.ContainerRegistry/registries/repositories/content/write",
      "Microsoft.ContainerRegistry/registries/repositories/metadata/read",
      "Microsoft.ContainerRegistry/registries/repositories/metadata/write",
    ]
  }

  assignable_scopes = [
    module.acr.acr_id,
  ]
}

resource "azurerm_role_assignment" "github_actions_acr_build_executor" {
  scope              = module.acr.acr_id
  role_definition_id = azurerm_role_definition.acr_build_executor.role_definition_resource_id
  principal_id       = module.managed_identities.identities.github_actions_deploy.principal_id
}
