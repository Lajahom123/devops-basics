resource "azuread_application" "github_actions_dev_operator" {
  display_name = "github-${var.project_name}-${var.environment}-dev-operator"
}

resource "azuread_service_principal" "github_actions_dev_operator" {
  client_id = azuread_application.github_actions_dev_operator.client_id
}

resource "azuread_application_federated_identity_credential" "github_dev_operator_environment" {
  application_id = azuread_application.github_actions_dev_operator.id

  display_name = "github-dev-operations"
  description  = "GitHub Actions OIDC for dev operations in ${var.github_owner}/${var.github_repo}"

  audiences = [
    "api://AzureADTokenExchange"
  ]

  issuer = "https://token.actions.githubusercontent.com"

  subject = "repo:${var.github_owner}/${var.github_repo}:environment:dev-operations"
}