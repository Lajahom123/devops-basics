# Terraform infrastructure

This folder contains the Azure infrastructure definition for the DevOps tracker project.

## Resources

Terraform provisions:

- Resource group
- Azure Container Registry
- Linux App Service plan
- Linux Web App
- Virtual network
- App Service delegated subnet
- PostgreSQL delegated subnet
- Private DNS zone for PostgreSQL
- Azure PostgreSQL Flexible Server
- PostgreSQL database
- Azure Key Vault
- Key Vault secret for `DATABASE_URL`
- User assigned managed identity for Key Vault references
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

The Web App also uses a user assigned managed identity for Key Vault references.
The database connection string is stored as a Key Vault secret and exposed to the
container as the `DATABASE_URL` app setting.

## Private database networking

PostgreSQL Flexible Server is deployed with private network access:

- Public PostgreSQL access is disabled.
- The server is attached to a subnet delegated to `Microsoft.DBforPostgreSQL/flexibleServers`.
- App Service is integrated with a separate subnet delegated to `Microsoft.Web/serverFarms`.
- A private DNS zone named `privatelink.postgres.database.azure.com` is linked to the VNet.
- App Service routes outbound traffic through the VNet.

This requires an App Service plan SKU that supports VNet integration. Use `B1` or higher for this project.

## Secrets and state

Terraform generates the PostgreSQL administrator password and writes the full
database connection string to Key Vault.

These values are also present in Terraform state. Keep local state files out of
Git and move to an Azure Storage remote backend before treating this as a shared
or production-like environment.

## Apply

From this directory:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

After apply, redeploy the container image through GitHub Actions or manually
restart the Web App so it resolves the latest Key Vault reference.

## Files

```text
main.tf
variables.tf
outputs.tf
terraform.tfvars.example
README.md
