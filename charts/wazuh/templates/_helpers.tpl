{{- define "wazuh.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "wazuh.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "wazuh.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{- define "wazuh.labels" -}}
helm.sh/chart: {{ include "wazuh.chart" . }}
app.kubernetes.io/name: {{ include "wazuh.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.podLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "wazuh.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wazuh.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "wazuh.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "wazuh.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "wazuh.ingressAnnotations" -}}
{{- $provider := .Values.cloud.provider | default "generic" -}}
{{- $anns := dict -}}
{{- if and (.Values.cloud.lbAnnotations) (ne $provider "generic") -}}
{{- $_ := merge $anns .Values.cloud.lbAnnotations -}}
{{- end -}}
{{- with .Values.ingress.annotations -}}
{{- $_ := merge $anns . -}}
{{- end -}}
{{ toYaml $anns }}
{{- end -}}
