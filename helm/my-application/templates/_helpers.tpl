# (This file remains unchanged)

{{- define "my-application.name" -}}{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}{{- end -}}
{{- define "my-application.fullname" -}}
{{- if .Values.fullnameOverride -}}{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}{{- end -}}{{- end -}}
{{- define "my-application.chart" -}}{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}{{- end -}}
{{- define "my-application.labels" -}}
helm.sh/chart: {{ include "my-application.chart" . }}
{{ include "my-application.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
{{- define "my-application.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-application.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- define "my-application.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "my-application.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}
