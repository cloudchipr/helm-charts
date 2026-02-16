{{/*
Expand the name of the chart.
*/}}
{{- define "c8r.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
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
{{ include "c8r.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Base selector labels
*/}}
{{- define "c8r.selectorLabels" -}}
app.kubernetes.io/name: {{ include "c8r.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
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
Server service host for agent discovery
*/}}
{{- define "c8r.serverServiceHost" -}}
{{- if .Values.configuration.agent.serverServiceHost }}
{{- .Values.configuration.agent.serverServiceHost }}
{{- else }}
{{- printf "%s-server.%s.svc.cluster.local" (include "c8r.fullname" .) .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
ConfigMap checksum for rolling updates
*/}}
{{- define "c8r.configmap.checksum" -}}
checksum/configmap: {{ include (print $.Template.BasePath "/configMap.yaml") . | sha256sum }}
{{- end }}

{{/*
Image reference
*/}}
{{- define "c8r.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Priority class name
*/}}
{{- define "c8r.priorityClassName" -}}
{{- if .Values.priorityClass.enabled }}
{{- .Values.priorityClass.name | default (printf "%s-priority" (include "c8r.fullname" .)) }}
{{- end }}
{{- end }}

{{/*
Global extra environment variables
*/}}
{{- define "c8r.extraEnv" -}}
{{- with .Values.env }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Global envFrom configuration
*/}}
{{- define "c8r.envFrom" -}}
{{- if .Values.envFrom }}
envFrom:
{{- toYaml .Values.envFrom | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Agent environment variables
*/}}
{{- define "c8r.agentEnv" -}}
- name: GOMAXPROCS
  valueFrom:
    resourceFieldRef:
      resource: limits.cpu
      divisor: "1"
- name: GOMEMLIMIT
  valueFrom:
    resourceFieldRef:
      resource: limits.memory
      divisor: "1"
- name: NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: POD_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: COLLECTION_INTERVAL
  value: {{ .Values.configuration.agent.collectionInterval | quote }}
- name: SKIP_CONNTRACK_SANITY_CHECK
  value: {{ .Values.configuration.agent.skipConntrackSanityCheck | quote }}
- name: KUBENETMON_SERVER_SERVICE_HOST
  value: {{ include "c8r.serverServiceHost" . | quote }}
- name: KUBENETMON_SERVER_SERVICE_PORT
  value: {{ .Values.configuration.agent.serverServicePort | quote }}
- name: METRICS_PORT
  value: {{ .Values.metrics.port | quote }}
- name: UPTIME_WAIT_DURATION
  value: {{ .Values.configuration.agent.uptimeWaitDuration | quote }}
{{- with .Values.env }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Server environment variables
*/}}
{{- define "c8r.serverEnv" -}}
- name: GOMAXPROCS
  valueFrom:
    resourceFieldRef:
      resource: limits.cpu
      divisor: "1"
- name: GOMEMLIMIT
  valueFrom:
    resourceFieldRef:
      resource: limits.memory
      divisor: "1"
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: POD_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
{{- with .Values.env }}
{{ toYaml . }}
{{- end }}
{{- end }}
