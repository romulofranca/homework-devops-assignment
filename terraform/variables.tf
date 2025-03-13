variable "namespace" {
  description = "The Kubernetes namespace to deploy the Hello World application into."
  type        = string
  default     = "default"
}

variable "release_name" {
  description = "The Helm release name for the Hello World application."
  type        = string
  default     = "hello-app"
}
