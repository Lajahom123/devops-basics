output "deploy_client_id" {
  description = "GitHub deploy application client ID."
  value       = azuread_application.deploy.client_id
}

output "deploy_principal_id" {
  description = "GitHub deploy service principal object ID."
  value       = azuread_service_principal.deploy.object_id
}

output "dev_operator_client_id" {
  description = "GitHub dev operator application client ID, when created."
  value       = try(azuread_application.dev_operator[0].client_id, null)
}

output "dev_operator_principal_id" {
  description = "GitHub dev operator service principal object ID, when created."
  value       = try(azuread_service_principal.dev_operator[0].object_id, null)
}
