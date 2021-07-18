# About this module

This module can install Prometheus Grafana Thanos.

## How to change infrastructure

 * New namespace will be create (by default name "monitoring")
 * New 3 application for ArgoCD (grafana, prometheus, thanos) 
 * New ingress and dns records will be create (thanos.domain.name, grafana.domain.name). You can disable create ingress if provide additional config (grafana_conf = {ingress.enabled = false} and thanos_conf = {queryFrontend.ingress.enabled = false}
 * By default, thanos backend will be create s3 bucket "<domain_name>-thanos and IAM policy. 
## Prometheus
Install the [kube-prometheus](https://github.com/bitnami/charts/tree/master/bitnami/kube-prometheus), de-facto standard for monitoring.
## Grafana
Install the [grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana), web dashboarding system
## Thanos
Install the [thanos](https://github.com/bitnami/charts/tree/master/bitnami/thanos), long term storage capabilities for prometheus
## Example
``` hcl
module "prometheus" {
  depends_on      = [module.argocd]
  source          = "github.com/provectus/sak-prometheus"
  cluster_name    = module.kubernetes.cluster_name
  argocd          = module.argocd.state
  domains         = local.domain
  tags            = local.tags
}
```

Optional parameters
```
  namespace               = "moniroting" # Set namespace to install all charts
  thanos_enabled          = true # Enable install thanos application
  grafana_enabled         = true # Enable install prometheus application
  prometheus_enabled      = true # Enable install grafana application
  thanos_storage          = "s3" # Object storage backend. 
  thanos_password         = "password" # Use as minio secret if thanos_storage = "minio"
  grafana_password        = "password" # Set grafana admin password, autogenerate and store to paramstore if empty
  grafana_google_auth     = true
  grafana_client_id       = "xxxxx"
  grafana_client_secret   = "xxxxx"
  grafana_allowed_domains = "example.com"
  thanos_conf             = {} # Additional thanos configurations
  grafana_conf            = {} # Additional grafana configurations
  prometheus_conf         = {} # Additional prometheus configurations
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| helm | n/a |
| kubernetes | n/a |
| local | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| argocd | A set of values for enabling deployment through ArgoCD | `map(string)` | `{}` | no |
| cluster\_name | A name of the Amazon EKS cluster | `string` | `null` | no |
| domains | A list of domains to use for ingresses | `list(string)` | <pre>[<br>  "local"<br>]</pre> | no |
| grafana\_allowed\_domains | Allowed domain for Grafana Google auth | `string` | `"local"` | no |
| grafana\_chart\_version | A Grafana Chart version | `string` | `"6.13.9"` | no |
| grafana\_client\_id | The id of the client for Grafana Google auth | `string` | `""` | no |
| grafana\_client\_secret | The token of the client for Grafana Google auth | `string` | `""` | no |
| grafana\_conf | A custom configuration for deployment | `map(string)` | `{}` | no |
| grafana\_google\_auth | Enables Google auth for Grafana | `string` | `false` | no |
| grafana\_password | Password for grafana admin | `string` | `""` | no |
| module\_depends\_on | A list of explicit dependencies | `list(any)` | `[]` | no |
| namespace | A name of the existing namespace | `string` | `""` | no |
| namespace\_name | A name of namespace for creating | `string` | `"monitoring"` | no |
| prometheus\_chart\_version | A Prometheus Chart version | `string` | `"6.1.1"` | no |
| prometheus\_conf | A custom configuration for deployment | `map(string)` | `{}` | no |
| tags | A tags for attaching to new created AWS resources | `map(string)` | `{}` | no |
| thanos\_chart\_version | A Thanos Chart version | `string` | `"5.1.0"` | no |
| thanos\_conf | A custom configuration for deployment | `map(string)` | `{}` | no |
| thanos\_password | Password for thanos objstorage if thanos\_storage minio | `string` | `""` | no |
| thanos\_storage | The type of thanos object storage backend | `string` | `"s3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| path\_to\_grafana\_password | A SystemManager ParemeterStore key with Grafana admin password |

