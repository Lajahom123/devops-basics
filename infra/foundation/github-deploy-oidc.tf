resource "azuread_application" "github_actions_deploy" {
  display_name = "github-${var.project_name}-${var.environment}-deploy"
}

resource "azuread_service_principal" "github_actions_deploy" {
  client_id = azuread_application.github_actions_deploy.client_id
}

resource "azuread_application_federated_identity_credential" "github_branch_deploy" {
  application_id = azuread_application.github_actions_deploy.id

  display_name = "github-${var.github_branch}"
  description  = "GitHub Actions OIDC for ${var.github_owner}/${var.github_repo} on ${var.github_branch}"

  audiences = [
    "api://AzureADTokenExchange"
  ]

  issuer = "https://token.actions.githubusercontent.com"

  subject = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
}