{{- /*
Validation helpers for c8r-network-agent Helm chart
These templates validate configuration values and fail with helpful messages
*/ -}}

{{/*
Validate ClickHouse configuration when inserter is enabled
*/}}
{{- define "c8r.validateInserter" -}}
{{- if .Values.inserter.enabled -}}
  {{- if not .Values.inserter.endpoint -}}
    {{- fail "ERROR: inserter.endpoint is required when inserter.enabled is true" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate resource configuration
*/}}
{{- define "c8r.validateResources" -}}
{{- if not .Values.resources.agent -}}
  {{- fail "ERROR: resources.agent configuration is required" -}}
{{- end -}}
{{- if not .Values.resources.server -}}
  {{- fail "ERROR: resources.server configuration is required" -}}
{{- end -}}
{{- end -}}

{{/*
Validate service configuration
*/}}
{{- define "c8r.validateService" -}}
{{- $validTypes := list "ClusterIP" "NodePort" "LoadBalancer" -}}
{{- if not (has .Values.service.type $validTypes) -}}
  {{- fail (printf "ERROR: service.type must be one of: %s" (join ", " $validTypes)) -}}
{{- end -}}
{{- end -}}

{{/*
Main validation - called from deployment/daemonset
*/}}
{{- define "c8r.validateAll" -}}
{{- include "c8r.validateInserter" . -}}
{{- include "c8r.validateResources" . -}}
{{- include "c8r.validateService" . -}}
{{- end -}}
