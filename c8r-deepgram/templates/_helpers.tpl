{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts.
*/}}
{{- define "namespace" -}}
    {{- if and .Values.namespaceOverride -}}
        {{- print .Values.namespaceOverride -}}
    {{- else -}}
        {{- print .Release.Namespace -}}
    {{- end }}
{{- end -}}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Release.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Common labels other
*/}}
{{- define "labelsOther" -}}
helm.sh/chart: {{ include "chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Common labels proxy
*/}}
{{- define "labelsLicenseProxy" -}}
helm.sh/chart: {{ include "chart" . }}
{{ include "selectorLabelsLicenseProxy" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels proxy
*/}}
{{- define "selectorLabelsLicenseProxy" -}}
app.kubernetes.io/name: {{ (.Values.licenseProxy.name | default (printf "%s-license-proxy" .Release.Name)) }}
app.kubernetes.io/instance: {{ (.Values.licenseProxy.name | default (printf "%s-license-proxy" .Release.Name)) }}
{{- end }}


{{/*
Common labels api
*/}}
{{- define "labelsApi" -}}
helm.sh/chart: {{ include "chart" . }}
{{ include "selectorLabelsApi" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels api
*/}}
{{- define "selectorLabelsApi" -}}
app.kubernetes.io/name: {{ (.Values.licenseProxy.name | default (printf "%s-api" .Release.Name)) }}
app.kubernetes.io/instance: {{ (.Values.licenseProxy.name | default (printf "%s-api" .Release.Name)) }}
{{- end }}

{{/*
Common labels engine
*/}}
{{- define "labelsEngine" -}}
helm.sh/chart: {{ include "chart" . }}
{{ include "selectorLabelsEngine" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels engine
*/}}
{{- define "selectorLabelsEngine" -}}
app.kubernetes.io/name: {{ (.Values.licenseProxy.name | default (printf "%s-engine" .Release.Name)) }}
app.kubernetes.io/instance: {{ (.Values.licenseProxy.name | default (printf "%s-engine" .Release.Name)) }}
{{- end }}

{{/*
Common labels sidecar
*/}}
{{- define "labelsSidecar" -}}
helm.sh/chart: {{ include "chart" . }}
{{ include "selectorLabelsSidecar" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels sidecar
*/}}
{{- define "selectorLabelsSidecar" -}}
app.kubernetes.io/name: {{ (.Values.licenseProxy.name | default (printf "%s-engine-api" .Release.Name)) }}
app.kubernetes.io/instance: {{ (.Values.licenseProxy.name | default (printf "%s-engine-api" .Release.Name)) }}
{{- end }}
