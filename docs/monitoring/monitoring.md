# Monitoring

The project uses Azure Monitor with a Log Analytics Workspace as the central query and storage backend. Monitoring resources live in `infra/runtime` because they are tied to the active application environment and can be recreated with runtime.

## Components

- Log Analytics Workspace stores platform logs, metrics, and Application Insights data.
- Application Insights is connected to the Web App through app settings.
- Diagnostic settings export Azure resource logs and metrics to Log Analytics.
- Azure Monitor scheduled query alerts evaluate KQL against Log Analytics.
- An Action Group sends email notifications to `owner_email`.

## Current diagnostics

Diagnostic settings are enabled for:

- Linux Web App
- Container Apps Environment
- PostgreSQL Flexible Server
- Key Vault

The diagnostic setting resources use Azure-provided diagnostic categories dynamically, so category availability can vary by Azure resource type and provider behavior.

## Current alert

`alert-failed-requests` queries `AppRequests` and triggers when failed requests exceed the configured threshold in the alert window. The cadence is controlled by:

- `alert_evaluation_frequency`
- `alert_window_duration`

Both default to `PT5M` and are documented in `infra/runtime/terraform.tfvars.example`.

## Useful queries

Failed requests:

```kql
AppRequests
| where Success == false
| order by TimeGenerated desc
```

Recent exceptions:

```kql
AppExceptions
| order by TimeGenerated desc
```

Dependency failures:

```kql
AppDependencies
| where Success == false
| order by TimeGenerated desc
```

Container Apps migration job logs:

```kql
ContainerAppConsoleLogs_CL
| where ContainerAppName_s contains "migrations"
| order by TimeGenerated desc
```

PostgreSQL logs:

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.DBFORPOSTGRESQL"
| order by TimeGenerated desc
```

Key Vault audit events:

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| order by TimeGenerated desc
```

## Operational notes

Application health checks currently hit `/health`, which reports dependency status. That is useful while validating the platform, but it means database or network issues may show up as application health failures.

The deployment workflow also uses `/health` and `/version` for staging and production verification. If Web App public access is restricted later, those checks need to run from a private network path.
