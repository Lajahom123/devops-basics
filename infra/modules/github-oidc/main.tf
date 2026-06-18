resource "azuread_application" "deploy" {
  display_name = "github-${var.project}-${var.environment}-deploy"
}

resource "azuread_service_principal" "deploy" {
  client_id = azuread_application.deploy.client_id
}

resource "azuread_application_federated_identity_credential" "branch_deploy" {
  application_id = azuread_application.deploy.id
  display_name   = "github-${var.github_branch}"
  description    = "GitHub Actions OIDC for ${var.github_owner}/${var.github_repo} on ${var.github_branch}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
}

resource "azuread_application" "dev_operator" {
  count = var.create_dev_operator ? 1 : 0

  display_name = "github-${var.project}-${var.environment}-dev-operator"
}

resource "azuread_service_principal" "dev_operator" {
  count = var.create_dev_operator ? 1 : 0

  client_id = azuread_application.dev_operator[0].client_id
}

resource "azuread_application_federated_identity_credential" "dev_operator_environment" {
  count = var.create_dev_operator ? 1 : 0

  application_id = azuread_application.dev_operator[0].id
  display_name   = "github-dev-operations"
  description    = "GitHub Actions OIDC for dev operations in ${var.github_owner}/${var.github_repo}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_owner}/${var.github_repo}:environment:dev-operations"
}
