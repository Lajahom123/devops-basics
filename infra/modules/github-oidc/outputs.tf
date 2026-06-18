output "federated_credential_id" {
  description = "Federated identity credential ID."
  value       = azurerm_federated_identity_credential.deploy.id
}

output "federated_credential_name" {
  description = "Federated identity credential name."
  value       = azurerm_federated_identity_credential.deploy.name
}

output "subject" {
  description = "GitHub OIDC subject allowed by the federated credential."
  value       = azurerm_federated_identity_credential.deploy.subject
}
