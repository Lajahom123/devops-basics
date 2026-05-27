resource "azurerm_network_interface" "github_runner" {
  name                = "nic-github-runner-dev"
  location            = var.location
  resource_group_name = data.terraform_remote_state.foundation.outputs.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.foundation.outputs.github_runner_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}