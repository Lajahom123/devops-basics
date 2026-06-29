# Operations notes

This project is small enough to reason about, but it already has production-inspired operational boundaries: private DNS, private endpoints, managed identities, slot swaps, and separate platform/runtime lifecycles.

## Deploy

Apply platform first, then runtime:

```bash
cd infra/platform
terraform init
terraform apply

cd ../runtime
terraform init
terraform apply
```

Application deployment is handled by GitHub Actions. Deployment operations use GitHub-hosted runners with OIDC. Private endpoint validation runs on the self-hosted runner inside the VNet.

## Validate private connectivity

Run private checks from the self-hosted runner, an admin VM, or another approved private network path:

```bash
nslookup <web-app-name>.azurewebsites.net
nslookup <web-app-name>-staging.azurewebsites.net
curl --fail https://<web-app-name>.azurewebsites.net/health
curl --fail https://<web-app-name>-staging.azurewebsites.net/health
```

These checks should resolve through `privatelink.azurewebsites.net` inside the VNet. A laptop outside the VNet usually cannot perform the same validation.

## Verify NAT outbound IP

Run this from the self-hosted runner:

```bash
curl --fail --silent --show-error https://ifconfig.me
```

The result should match the platform `nat_public_ip` output. NAT Gateway only controls outbound egress for associated subnets; it does not provide inbound access or policy enforcement.

## Common troubleshooting points

- Private DNS: production and staging App Service hostnames must resolve to private endpoint addresses from inside the VNet.
- App Service access: direct public access is disabled, so hosted runners cannot validate App Service through its public hostname.
- Front Door: public user traffic should enter through Front Door and reach App Service over Private Link.
- Runner registration: the VM uses managed identity to read GitHub App configuration from Key Vault, then registers a persistent runner.
- Runner labels: private validation jobs require the self-hosted VNet labels to land on the runner.
- PostgreSQL: private networking failures can look like application or authentication failures.
- Slot swaps: staging must contain a meaningful release candidate before swap, and rollback depends on what remains in staging.
- Terraform lifecycle: destroy runtime for cost control; do not destroy platform during routine cleanup.

## Database administration

Terraform creates the Azure database service and identities, but database-level principal mapping and grants may still need a private administration path.

Managed identity auth requires:

- Entra authentication enabled on PostgreSQL;
- PostgreSQL principal mapped to the App Service managed identity;
- schema and table grants for that principal;
- token refresh behavior in the application connection path.

Password authentication remains available for bootstrap and migrations. Treat it as privileged operational access.
