variable "argocd" {
  type        = map(string)
  description = "A set of values for enabling deployment through ArgoCD"
  default     = {}
}

variable "prometheus_enabled" {
  type        = bool
  description = "Enable install prometheus"
  default     = true
}

variable "thanos_enabled" {
  type        = bool
  description = "Enable install thanos"
  default     = true
}

variable "grafana_enabled" {
  type        = bool
  description = "Enable install grafana"
  default     = true
}

variable "grafana_conf" {
  type        = map(string)
  description = "A custom configuration for deployment"
  default     = {}
}

variable "prometheus_conf" {
  type        = map(string)
  description = "A custom configuration for deployment"
  default     = {}
}

variable "thanos_conf" {
  type        = map(string)
  description = "A custom configuration for deployment"
  default     = {}
}

variable "namespace" {
  type        = string
  default     = ""
  description = "A name of the existing namespace"
}

variable "namespace_name" {
  type        = string
  default     = "monitoring"
  description = "A name of namespace for creating"
}

variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}

variable "domains" {
  type        = list(string)
  default     = ["local"]
  description = "A list of domains to use for ingresses"
}

variable "grafana_chart_version" {
  type        = string
  description = "A Grafana Chart version"
  default     = "6.13.9"
}

variable "prometheus_chart_version" {
  type        = string
  description = "A Prometheus Chart version"
  default     = "6.1.1"
}

variable "thanos_chart_version" {
  type        = string
  description = "A Thanos Chart version"
  default     = "5.1.0"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A tags for attaching to new created AWS resources"
}

variable "thanos_storage" {
  type        = string
  description = "The type of thanos object storage backend"
  default     = "s3"
}

variable "thanos_password" {
  type        = string
  description = "Password for thanos objstorage if thanos_storage minio"
  default     = ""
}

variable "grafana_password" {
  type        = string
  description = "Password for grafana admin"
  default     = ""
}

variable "grafana_google_auth" {
  type        = string
  description = "Enables Google auth for Grafana"
  default     = false
}

variable "grafana_client_id" {
  type        = string
  description = "The id of the client for Grafana Google auth"
  default     = ""
}

variable "grafana_client_secret" {
  type        = string
  description = "The token of the client for Grafana Google auth"
  default     = ""
}

variable "grafana_allowed_domains" {
  type        = string
  description = "Allowed domain for Grafana Google auth"
  default     = "local"
}
