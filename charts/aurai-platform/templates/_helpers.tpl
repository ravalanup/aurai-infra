{{/* Common labels applied to every resource. */}}
{{- define "aurai.labels" -}}
app.kubernetes.io/part-of: aurai
app.kubernetes.io/managed-by: {{ .Release.Service }}
aurai.io/environment: {{ .Values.global.environment | quote }}
{{- end }}

{{/* Selector labels. Call with: include "aurai.selectorLabels" (dict "name" "postgres" "root" .) */}}
{{- define "aurai.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- end }}

{{/* Pod-level security defaults. */}}
{{- define "aurai.podSecurityContext" -}}
seccompProfile:
  type: RuntimeDefault
{{- end }}
