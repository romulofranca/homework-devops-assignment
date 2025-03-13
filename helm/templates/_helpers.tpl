{{/*
Return the name of the application.
*/}}
{{- define "hello-app.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the full name of the application.
If the release name is the same as the base name, it returns only the base name;
otherwise, it concatenates them.
*/}}
{{- define "hello-app.fullname" -}}
  {{- $name := default .Chart.Name .Values.nameOverride -}}
  {{- if eq .Release.Name $name -}}
    {{- $name | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}
