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
