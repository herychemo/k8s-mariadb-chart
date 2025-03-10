{{/*
Expand the name of the chart.
*/}}
{{- define "k8s-mariadb-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "k8s-mariadb-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "k8s-mariadb-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "k8s-mariadb-chart.labels" -}}
helm.sh/chart: {{ include "k8s-mariadb-chart.chart" . }}
{{ include "k8s-mariadb-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k8s-mariadb-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-mariadb-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Returns true if secret name was not provided, so chart must create it.
*/}}
{{- define "k8s-mariadb-chart.createSecret" -}}
{{- if not .Values.secretName }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Returns the secret name to be used for auth.
*/}}
{{- define "k8s-mariadb-chart.getSecretName" -}}
{{- if not .Values.auth.secretName }}
    {{- include "k8s-mariadb-chart.fullname" . -}}-secret
{{- else -}}
    {{- .Values.auth.secretName -}}
{{- end -}}
{{- end -}}

{{/*
Prints the init containers required environment vars.
*/}}
{{- define "k8s-mariadb-chart.initContainerEnv" -}}
- name: SERVER_ID_OFFSET
  valueFrom:
    configMapKeyRef:
      name: "{{ include "k8s-mariadb-chart.fullname" . }}-configmap"
      key: server-id-offset
- name: DATABASE_NAME
  valueFrom:
    configMapKeyRef:
      name: "{{ include "k8s-mariadb-chart.fullname" . }}-configmap"
      key: database-name
- name: NAMESPACE
  valueFrom:
    configMapKeyRef:
      name: "{{ include "k8s-mariadb-chart.fullname" . }}-configmap"
      key: namespace
- name: STATEFULSET_NAME
  value: "{{ include "k8s-mariadb-chart.fullname" . }}-statefulset"
- name: SVC_NAME
  value: "{{ include "k8s-mariadb-chart.fullname" . }}-service"
- name: DATABASE_REPLICATION_USER_USERNAME
  valueFrom:
    secretKeyRef:
      name: "{{ include "k8s-mariadb-chart.getSecretName" . }}"
      key: mariadb-replication-username
- name: DATABASE_REPLICATION_USER_PASSWORD
  valueFrom:
    secretKeyRef:
      name: "{{ include "k8s-mariadb-chart.getSecretName" . }}"
      key: mariadb-replication-password
{{- end -}}
