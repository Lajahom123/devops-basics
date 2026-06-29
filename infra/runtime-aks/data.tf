data "terraform_remote_state" "platform" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-devops-tracker-dev-tfstate"
    storage_account_name = "stdevopstrackerswedenct"
    container_name       = "full-infra"
    key                  = "platform.tfstate"
  }
}
