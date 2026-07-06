{{/*
Common metadata labels for one-shot Jobs and their ServiceAccounts.
Expected context: (dict "root" . "jobName" "<job-name>")
*/}}
{{- define "devops-tracker-jobs.job.labels" -}}
app.kubernetes.io/name: {{ .jobName }}
{{- include "devops-tracker-jobs.labels" .root | nindent 0 }}
{{- end }}

{{/*
Pod template labels for Workload Identity Jobs.
Expected context: (dict "root" . "jobName" "<job-name>")
*/}}
{{- define "devops-tracker-jobs.job.podLabels" -}}
app.kubernetes.io/name: {{ .jobName }}
app.kubernetes.io/part-of: {{ .root.Values.jobs.partOf }}
azure.workload.identity/use: {{ .root.Values.jobs.workloadIdentity.use | quote }}
{{- end }}

{{/*
Shared pod securityContext, restartPolicy, tmp volume for Jobs.
Expected context: root chart context (.)
*/}}
{{- define "devops-tracker-jobs.job.podSpec" -}}
restartPolicy: {{ .Values.jobs.restartPolicy }}
securityContext:
  {{- toYaml .Values.jobs.podSecurityContext | nindent 2 }}
volumes:
  - name: {{ .Values.jobs.tmpVolume.name }}
    emptyDir: {}
{{- end }}

{{/*
Shared container securityContext for Jobs.
Expected context: root chart context (.)
*/}}
{{- define "devops-tracker-jobs.job.containerSecurityContext" -}}
securityContext:
  {{- toYaml .Values.jobs.containerSecurityContext | nindent 2 }}
{{- end }}

{{/*
Shared tmp volumeMount for Jobs.
Expected context: root chart context (.)
*/}}
{{- define "devops-tracker-jobs.job.tmpVolumeMount" -}}
volumeMounts:
  - name: {{ .Values.jobs.tmpVolume.name }}
    mountPath: {{ .Values.jobs.tmpVolume.mountPath }}
{{- end }}

{{/*
Shared Azure Workload Identity env vars for Jobs.
Expected context: (dict "root" . "clientId" "<client-id>")
*/}}
{{- define "devops-tracker-jobs.job.azureEnv" -}}
- name: AZURE_CONFIG_DIR
  value: {{ .root.Values.jobs.azure.configDir | quote }}
- name: AZURE_CLIENT_ID
  value: {{ .clientId | quote }}
- name: AZURE_TENANT_ID
  value: {{ include "devops-tracker-jobs.azureTenantId" .root | quote }}
{{- end }}
