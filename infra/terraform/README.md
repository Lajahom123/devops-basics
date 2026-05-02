# Terraform infrastructure

This folder contains the Azure infrastructure definition for the DevOps tracker project.

## Resources

Terraform provisions:

- Resource group
- Azure Container Registry
- Linux App Service plan
- Linux Web App
- Log Analytics workspace
- Application Insights
- Managed identity configuration
- AcrPull role assignment

## Authentication model

The Web App uses a system assigned managed identity.

That identity receives the `AcrPull` role on the Azure Container Registry.

This means the Web App can pull Docker images from ACR without storing registry credentials in:

- GitHub secrets
- Terraform variables
- App Service app settings
- deployment scripts

## Files

```text
main.tf
variables.tf
outputs.tf
terraform.tfvars.example
README.md