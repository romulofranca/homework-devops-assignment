output "helm_release_name" {
  description = "The Helm release name for the Hello World application."
  value       = helm_release.hello_app.name
}

output "helm_release_namespace" {
  description = "The Kubernetes namespace in which the application is deployed."
  value       = helm_release.hello_app.namespace
}
