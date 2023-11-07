{{/*
Expand the name of the chart.
*/}}
{{- define "c8r-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "c8r-agent.fullname" -}}
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
{{- define "c8r-agent.chart" -}}
{{- if index .Values "$chart_tests" }}
{{- printf "%s" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "c8r-agent.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "c8r-agent.labels" -}}
helm.sh/chart: {{ include "c8r-agent.chart" . }}
{{ include "c8r-agent.selectorLabels" . }}
{{- if index .Values "$chart_tests" }}
app.kubernetes.io/version: "vX.Y.Z"
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- else }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "c8r-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "c8r-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "c8r-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "c8r-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Calculate name of image ID to use for "c8r-agent".
*/}}
{{- define "c8r-agent.imageId" -}}
{{- if .Values.image.digest }}
{{- $digest := .Values.image.digest }}
{{- if not (hasPrefix "sha256:" $digest) }}
{{- $digest = printf "sha256:%s" $digest }}
{{- end }}
{{- printf "@%s" $digest }}
{{- else if .Values.image.tag }}
{{- printf ":%s" .Values.image.tag }}
{{- else }}
{{- printf ":%s" "v0.36.2" }}
{{- end }}
{{- end }}

{{/*
Calculate name of image ID to use for "config-reloader".
*/}}
{{- define "config-reloader.imageId" -}}
{{- if .Values.configReloader.image.digest }}
{{- $digest := .Values.configReloader.digest }}
{{- if not (hasPrefix "sha256:" $digest) }}
{{- $digest = printf "sha256:%s" $digest }}
{{- end }}
{{- printf "@%s" $digest }}
{{- else if .Values.configReloader.image.tag }}
{{- printf ":%s" .Values.configReloader.image.tag }}
{{- else }}
{{- printf ":%s" "v0.8.0" }}
{{- end }}
{{- end }}

{{/*
ClusterID
*/}}
{{- define "clusterId" -}}
{{- if not .Values.global.clusterId }}
{{- printf "Error: global.clusterId is required but not provided." | fail }}
{{- else -}}
{{- .Values.global.clusterId }}
{{- end -}}
{{- end -}}

{{/*
Endpint URL
*/}}
{{- define "endpointURL" -}}
{{- if not .Values.global.endpointURL }}
{{- printf "Error: global.endpointURL is required but not provided." | fail }}
{{- else -}}
{{- .Values.global.endpointURL }}
{{- end -}}
{{- end -}}

{{/*
Bearer token
*/}}
{{- define "bearerToken" -}}
{{- if not .Values.global.bearerToken }}
{{- printf "Error: global.bearerToken is required but not provided." | fail }}
{{- else -}}
{{- .Values.global.bearerToken }}
{{- end -}}
{{- end -}}
