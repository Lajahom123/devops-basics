resource "azurerm_linux_virtual_machine" "github_runner" {
  name                = "vm-github-runner-dev"
  location            = var.location
  resource_group_name = data.terraform_remote_state.platform.outputs.resource_group_name
  size                = "Standard_B1s"
  admin_username      = var.github_runner_admin_username

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.github_runner.id
  ]

  identity {
    type = "UserAssigned"

    identity_ids = [
      data.terraform_remote_state.platform.outputs.github_runner_identity_id
    ]
  }

  admin_ssh_key {
    username   = var.github_runner_admin_username
    public_key = file(var.github_runner_admin_ssh_public_key_path)
  }

  os_disk {
    name                 = "osdisk-github-runner-dev"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = local.common_tags
}

resource "azurerm_network_interface" "github_runner" {
  name                = "nic-github-runner-dev"
  location            = var.location
  resource_group_name = data.terraform_remote_state.platform.outputs.resource_group_name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.platform.outputs.github_runner_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine_extension" "github_runner_install" {
  name                 = "install-github-runner"
  virtual_machine_id   = azurerm_linux_virtual_machine.github_runner.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  tags                 = local.common_tags

  protected_settings = jsonencode({
    script = base64encode(templatefile("${path.module}/../../scripts/install-github-runner.sh", {
      key_vault_name = data.terraform_remote_state.platform.outputs.key_vault_name
    }))
  })
}