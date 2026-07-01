resource "azurerm_key_vault_secret" "appinsights_connection_string" {
  name         = "applicationinsights-connection-string"
  value        = module.monitoring.application_insights_connection_string
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [
    azurerm_role_assignment.current_deployer_key_vault_administrator,
  ]
}

resource "azurerm_role_assignment" "aks_workload_kv_appinsights_reader" {
  scope                = azurerm_key_vault_secret.appinsights_connection_string.resource_versionless_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.managed_identities.identities.aks_workload.principal_id
}
