{{/*
Expand the name of the chart.
*/}}
{{- define "devops-tracker-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "devops-tracker-api.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common app label used across all resources.
*/}}
{{- define "devops-tracker-api.labels" -}}
app: {{ include "devops-tracker-api.fullname" . }}
{{- end }}

{{/*
Selector labels used by Deployment, Service, and pod template.
*/}}
{{- define "devops-tracker-api.selectorLabels" -}}
app: {{ include "devops-tracker-api.fullname" . }}
{{- end }}

{{/*
Target namespace for all chart resources.
*/}}
{{- define "devops-tracker-api.namespace" -}}
{{- .Values.namespace }}
{{- end }}

{{/*
Fully qualified container image reference.
*/}}
{{- define "devops-tracker-api.image" -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "devops-tracker-api.serviceAccountName" -}}
{{- default (include "devops-tracker-api.fullname" .) .Values.serviceAccount.name }}
{{- end }}

{{/*
Microsoft Entra tenant ID shared by Workload Identity and Key Vault CSI.
*/}}
{{- define "devops-tracker-api.azureTenantId" -}}
{{- .Values.azure.tenantId }}
{{- end }}

{{/*
Application AKS workload identity client ID.
*/}}
{{- define "devops-tracker-api.azureClientId" -}}
{{- .Values.azure.clientId }}
{{- end }}

{{/*
PostgreSQL bootstrap Job workload identity client ID.
*/}}
{{- define "devops-tracker-api.postgresBootstrapClientId" -}}
{{- .Values.postgresBootstrap.managedIdentityClientId }}
{{- end }}

{{/*
Shared PostgreSQL connection settings used by the API and bootstrap Job.
*/}}
{{- define "devops-tracker-api.postgresHost" -}}
{{- .Values.postgres.host }}
{{- end }}

{{- define "devops-tracker-api.postgresPort" -}}
{{- .Values.postgres.port }}
{{- end }}

{{- define "devops-tracker-api.postgresDatabase" -}}
{{- .Values.postgres.database }}
{{- end }}

{{- define "devops-tracker-api.postgresUser" -}}
{{- .Values.postgres.user }}
{{- end }}
