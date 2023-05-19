# About this module

This module is part of Swiss Army Kube project. Check out main repo below and contributing guide.

**[Swiss Army Kube](https://github.com/provectus/swiss-army-kube)**
|
**[Contributing Guide](https://github.com/provectus/swiss-army-kube/blob/master/CONTRIBUTING.md)**

This module can install:

### Prometheus: [Documentation](https://prometheus.io/docs/introduction/overview/)

### Grafana: [Documentation](https://grafana.com/docs/)

### Thanos. [Documentation](https://thanos.io/tip/thanos/getting-started.md/)

## How to change infrastructure

- New namespace will be created (by default name "monitoring")
- New 3 applications for ArgoCD (grafana, prometheus, thanos)
- New ingress and dns records will be created (thanos.domain.name, grafana.domain.name). You can disable ingress if provide additional config (grafana_conf = {ingress.enabled = false} and thanos_conf = {queryFrontend.ingress.enabled = false}
- If ingress is disabled, you can test locally by port-forwarding (example: kubectl port-forward grafana-pod 3000:3000)
- By default, thanos backend will create s3 bucket "<domain_name>-thanos and IAM policy.

## Prometheus

Install the [kube-prometheus](https://github.com/bitnami/charts/tree/master/bitnami/kube-prometheus), de-facto standard for monitoring.

## Grafana

Install the [grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana), web dashboarding system

## Thanos

Install the [thanos](https://github.com/bitnami/charts/tree/master/bitnami/thanos), long term storage capabilities for prometheus

## Example

```hcl
module "prometheus" {
  depends_on      = [module.argocd]
  source          = "github.com/provectus/sak-prometheus"
  cluster_name    = module.eks.cluster_id
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

```
terraform >= 1.1
```

## Providers

| Name       | Version  |
| ---------- | -------- |
| aws        | >= 3.0   |
| helm       | >= 1.0   |
| kubernetes | >= 1.11  |
| local      | >= 2.1.0 |
| random     | >= 3.1.0 |

## Inputs

| Name                     | Description                                            | Type           | Default                       | Required |
| ------------------------ | ------------------------------------------------------ | -------------- | ----------------------------- | :------: |
| argocd                   | A set of values for enabling deployment through ArgoCD | `map(string)`  | `{}`                          |    no    |
| cluster_name             | A name of the Amazon EKS cluster                       | `string`       | `null`                        |    no    |
| domains                  | A list of domains to use for ingresses                 | `list(string)` | <pre>[<br> "local"<br>]</pre> |    no    |
| grafana_allowed_domains  | Allowed domain for Grafana Google auth                 | `string`       | `"local"`                     |    no    |
| grafana_chart_version    | A Grafana Chart version                                | `string`       | `"6.13.9"`                    |    no    |
| grafana_client_id        | The id of the client for Grafana Google auth           | `string`       | `""`                          |    no    |
| grafana_client_secret    | The token of the client for Grafana Google auth        | `string`       | `""`                          |    no    |
| grafana_conf             | A custom configuration for deployment                  | `map(string)`  | `{}`                          |    no    |
| grafana_enabled          | Enable install grafana                                 | `bool`         | `true`                        |    no    |
| grafana_google_auth      | Enables Google auth for Grafana                        | `string`       | `false`                       |    no    |
| grafana_password         | Password for grafana admin                             | `string`       | `""`                          |    no    |
| module_depends_on        | A list of explicit dependencies                        | `list(any)`    | `[]`                          |    no    |
| namespace                | A name of the existing namespace                       | `string`       | `""`                          |    no    |
| namespace_name           | A name of namespace for creating                       | `string`       | `"monitoring"`                |    no    |
| prometheus_chart_version | A Prometheus Chart version                             | `string`       | `"6.1.1"`                     |    no    |
| prometheus_conf          | A custom configuration for deployment                  | `map(string)`  | `{}`                          |    no    |
| prometheus_enabled       | Enable install prometheus                              | `bool`         | `true`                        |    no    |
| tags                     | A tags for attaching to new created AWS resources      | `map(string)`  | `{}`                          |    no    |
| thanos_chart_version     | A Thanos Chart version                                 | `string`       | `"5.1.0"`                     |    no    |
| thanos_conf              | A custom configuration for deployment                  | `map(string)`  | `{}`                          |    no    |
| thanos_enabled           | Enable install thanos                                  | `bool`         | `true`                        |    no    |
| thanos_password          | Password for thanos objstorage if thanos_storage minio | `string`       | `""`                          |    no    |
| thanos_storage           | The type of thanos object storage backend              | `string`       | `"s3"`                        |    no    |

## Outputs

| Name                     | Description                                                    |
| ------------------------ | -------------------------------------------------------------- |
| path_to_grafana_password | A SystemManager ParemeterStore key with Grafana admin password |
