locals {
  identities = {
    github_actions_deploy = "id-${var.name_prefix}-github-actions"
    aks_workload          = "id-${var.name_prefix}-aks-workload"
    migration_job         = "id-${var.name_prefix}-migration-job"
    github_runner         = "id-${var.name_prefix}-github-runner"
    private_runner        = "id-${var.name_prefix}-private-runner"
  }
}
