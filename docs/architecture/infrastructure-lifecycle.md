# Infrastructure lifecycle

Terraform is split by lifecycle rather than by Azure service type. Platform keeps persistent shared infrastructure stable; runtime contains workload resources that carry most active cost.

## Lifecycle layers

```mermaid
flowchart TD
  subgraph Platform["Platform: persistent shared infrastructure"]
    VNET["VNet and subnets"]
    ACR["ACR"]
    KV["Key Vault"]
    MON["Log Analytics + Application Insights"]
    DNS["Private DNS zones"]
    IDS["Managed identities"]
    OIDC["GitHub OIDC identities"]
    RBAC["Role assignments"]
    NAT["NAT Gateway"]
  end

  subgraph Runtime["Runtime: workload resources"]
    PLAN["App Service plan"]
    APP["App Service production slot"]
    SLOT["Staging slot"]
    PG["PostgreSQL Flexible Server"]
    CAJ["Container Apps migration job"]
    FD["Front Door"]
    PE["Production + staging private endpoints"]
    RUNNER["GitHub runner VM"]
    ALERTS["Diagnostics + alerts"]
  end

  Runtime -->|"terraform_remote_state"| Platform
  FD -->|"Private Link"| APP
  PE --> APP
  PE --> SLOT
  APP -->|"VNet integration"| VNET
  SLOT -->|"VNet integration"| VNET
  CAJ --> PG
  RUNNER --> PE
  RUNNER --> NAT
```

## Platform responsibilities

`infra/platform` owns:

- existing resource group lookup;
- VNet and subnets for App Service egress, PostgreSQL, admin access, Container Apps, private endpoints, and GitHub runner;
- ACR, Key Vault, Log Analytics, and Application Insights;
- PostgreSQL and App Service private DNS zones;
- user-assigned managed identities for App Service, migration job, and GitHub runner;
- GitHub OIDC deployment/operator identities;
- role assignments that belong to shared infrastructure;
- NAT Gateway and static outbound IP for the runner subnet.

Do not destroy this layer during normal cleanup. Recreating it can change identity principal IDs, private DNS links, and the runner network backbone.

## Runtime responsibilities

`infra/runtime` owns:

- App Service plan, production Web App, and staging slot;
- PostgreSQL Flexible Server and database;
- Container Apps Environment and Flyway migration job;
- Front Door Premium, WAF policy, route, and Private Link origin;
- production and staging App Service private endpoints;
- Ubuntu self-hosted GitHub runner VM with no public IP;
- workload diagnostic settings, alerting, and RBAC.

Runtime can be destroyed to remove most active cost while preserving platform.

## State separation

Platform and runtime use separate Terraform roots and separate state files. Runtime reads platform outputs through `terraform_remote_state`; it should not hardcode platform resource IDs.

This split keeps routine workload teardown from removing deployment identity, managed identities, ACR, Key Vault, DNS, NAT, or the VNet.

## Operating model

Initial apply order:

```bash
cd infra/platform
terraform init
terraform apply

cd ../runtime
terraform init
terraform apply
```

Cost control:

- stop PostgreSQL and App Service for short idle periods;
- destroy `infra/runtime` for longer idle periods;
- keep `infra/platform` unless retiring the project.

The next planned platform phase is AKS. The current split is intended to remain useful because networking, identity, monitoring, and private ingress foundations can be reused or extended.
