{{/*
Target namespace for all chart resources.
*/}}
{{- define "devops-tracker-jobs.namespace" -}}
{{- .Values.global.namespace }}
{{- end }}

{{/*
Microsoft Entra tenant ID for Workload Identity Jobs.
*/}}
{{- define "devops-tracker-jobs.azureTenantId" -}}
{{- .Values.global.tenantId }}
{{- end }}

{{/*
Common chart labels.
*/}}
{{- define "devops-tracker-jobs.labels" -}}
app.kubernetes.io/part-of: {{ .Values.jobs.partOf }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Shared PostgreSQL connection settings for bootstrap and migration Jobs.
*/}}
{{- define "devops-tracker-jobs.postgresHost" -}}
{{- .Values.postgres.host }}
{{- end }}

{{- define "devops-tracker-jobs.postgresPort" -}}
{{- .Values.postgres.port }}
{{- end }}

{{- define "devops-tracker-jobs.postgresDatabase" -}}
{{- .Values.postgres.database }}
{{- end }}

{{- define "devops-tracker-jobs.postgresAppUser" -}}
{{- .Values.postgres.appUser }}
{{- end }}

{{- define "devops-tracker-jobs.postgresMigrationUser" -}}
{{- .Values.postgres.migrationUser }}
{{- end }}
