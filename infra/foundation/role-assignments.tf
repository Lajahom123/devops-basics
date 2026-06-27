# Key Vault

resource "azurerm_role_assignment" "current_deployer_key_vault_administrator" {
  scope                = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "current_deployer_key_vault_data_access_administrator" {
  scope                = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Data Access Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# ACR

resource "azurerm_role_assignment" "github_actions_acr_build_executor" {
  scope              = module.acr.acr_id
  role_definition_id = "AcrPush"
  principal_id       = module.managed_identities.identities.github_actions_deploy.principal_id
}