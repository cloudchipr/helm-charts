{{/*
Expand the name of the chart.
*/}}
{{- define "c8r.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "c8r.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "c8r.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "c8r.labels" -}}
helm.sh/chart: {{ include "c8r.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Agent selector labels
*/}}
{{- define "c8r.agentSelectorLabels" -}}
app.kubernetes.io/name: {{ include "c8r.name" . }}-agent
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: agent
{{- end }}

{{/*
Server selector labels
*/}}
{{- define "c8r.serverSelectorLabels" -}}
app.kubernetes.io/name: {{ include "c8r.name" . }}-server
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: server
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "c8r.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "c8r.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Server service host for agent discovery (same namespace)
*/}}
{{- define "c8r.serverServiceHost" -}}
{{- printf "%s-server.%s.svc.cluster.local" (include "c8r.fullname" .) .Release.Namespace }}
{{- end }}

{{/*
configmap checksum calculator
*/}}
{{- define "c8r.configmap.checksum" -}}
{{- $fileContent := include (print .Template.BasePath "/configMap.yaml") . | fromYaml }}
checksum/configmap: {{ $fileContent.data | toYaml | sha256sum }}
{{- end }}

{{/*
secret checksum calculator
*/}}
{{- define "c8r.secret.checksum" -}}
{{- $fileContent := include (print .Template.BasePath "/secret.yaml") . | fromYaml }}
checksum/secret: {{ $fileContent.data | toYaml | sha256sum }}
{{- end }}
