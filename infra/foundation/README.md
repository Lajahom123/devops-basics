# Foundation layer

Persistent, low/no cost infrastructure that should survive normal runtime cleanup.

This layer reads the persistent resource group as data and owns the VNet, subnets, private DNS, user-assigned
managed identity, GitHub Actions OIDC identity, and foundational RBAC.

Do not run `terraform destroy` here during routine cost-management cycles.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

If resources already exist in Azure or in a previous monolithic state, import or
move state before applying to avoid duplicate creation.
