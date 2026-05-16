# Monitoring

The project uses Azure Monitor with a Log Analytics Workspace as the central query and storage backend.

## Components

- Application Insights collects application telemetry such as requests, exceptions and dependencies.
- Diagnostic settings export Azure platform and resource logs to Log Analytics.
- Log Analytics is used for KQL queries and investigation.
- Azure Monitor alerts evaluate KQL queries and trigger Action Groups.
- The Action Group currently sends email notifications.

## Current diagnostics

Enabled for:

- App Service
- Container App Environment
- PostgreSQL Flexible Server
- Key Vault

## Useful queries

Failed requests:

```kql
AppRequests
| where Success == false
| order by TimeGenerated desc