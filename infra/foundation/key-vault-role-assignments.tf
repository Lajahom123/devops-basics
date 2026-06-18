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
