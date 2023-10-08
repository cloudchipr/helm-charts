{{/*
Retrieve configMap name from the name of the chart or the ConfigMap the user
specified.
*/}}
{{- define "c8r-agent.config-map.name" -}}
{{- if .Values.agent.configMap.name -}}
{{- .Values.agent.configMap.name }}
{{- else -}}
{{- include "c8r-agent.fullname" . }}
{{- end }}
{{- end }}

{{/*
The name of the config file is the default or the key the user specified in the
ConfigMap.
*/}}
{{- define "c8r-agent.config-map.key" -}}
{{- if .Values.agent.configMap.key -}}
{{- .Values.agent.configMap.key }}
config.yaml
{{- else -}}
config.yaml
{{- end }}
{{- end }}
