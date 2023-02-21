locals {
  #Grafana
  grafana_name       = "grafana"
  grafana_repository = "https://grafana.github.io/helm-charts"
  grafana_chart      = "grafana"
  grafana_conf       = merge(local.grafana_conf_defaults, var.grafana_conf)
  grafana_password   = var.grafana_password == "" ? random_password.grafana_password.result : var.grafana_password
  # TODO: add ingress annotations config sections
  grafana_values = yamlencode(
    {
      "datasources.yaml" = {
        "apiVersion" = "1"
        "datasources" = [{
          "name"      = "Prometheus"
          "type"      = "prometheus"
          "url"       = "http://thanos-query:9090"
          "access"    = "proxy"
          "isDefault" = true
        }]
      }
      # "dashboards" = {
      #     "default" = {
      #       "prometheus-stats" = {
      #         "gnetId"     = "2"
      #         "revision"   = "2"
      #         "datasource" = "Prometheus"
      #       }
      #     }
      #   }
  })

  grafana_conf_defaults = {
    "ingress.enabled"           = true
    "ingress.ingressClassName"  = "nginx"
    "ingress.annotations"       = "{ kubernetes.io/tls-acme: 'true' }"
    "ingress.hosts[0]"          = "grafana.${var.domains[0]}"
    "ingress.tls[0].secretName" = "grafana-tls"
    "ingress.tls[0].hosts[0]"   = "grafana.${var.domains[0]}"

    "persistence.enabled" = true
    "persistence.size"    = "10Gi"

    "adminPassword"                      = local.argocd_enabled > 0 ? "KMS_ENC:${aws_kms_ciphertext.grafana_password[0].ciphertext_blob}:" : local.grafana_password
    "env.GF_SERVER_ROOT_URL"             = "https://grafana.${var.domains[0]}"
    "env.GF_AUTH_GOOGLE_ENABLED"         = var.grafana_google_auth
    "env.GF_AUTH_GOOGLE_ALLOWED_DOMAINS" = var.grafana_allowed_domains
    "env.GF_AUTH_GOOGLE_CLIENT_ID"       = var.grafana_client_id
    #//TODO: Change to work with secret
    "env.GF_AUTH_GOOGLE_CLIENT_SECRET" = var.grafana_client_secret
    "namespace"                        = local.namespace
  }
  grafana_application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.grafana_name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.grafana_repository
        "targetRevision" = var.grafana_chart_version
        "chart"          = local.grafana_chart
        "helm" = {
          "parameters" = values({
            for key, value in local.grafana_conf :
            key => {
              "name"  = key
              "value" = tostring(value)
            }
          })
          "values" = local.grafana_values
        }
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }

  #Prometheus
  prometheus_name       = "kube-prometheus"
  prometheus_repository = "https://charts.bitnami.com/bitnami"
  prometheus_chart      = "kube-prometheus"
  prometheus_conf       = merge(local.prometheus_conf_defaults, var.prometheus_conf)

  # TODO: add ingress annotations config sections
  prometheus_conf_defaults = {
    "alertmanager.enabled"                                                 = true
    "operator.enabled"                                                     = true
    "prometheus.enabled"                                                   = true
    "prometheus.ingress.enabled"                                           = false
    "prometheus.enableAdminAPI"                                            = true
    "prometheus.ingress.certManager"                                       = true
    "prometheus.ingress.hostname"                                          = "prometheus.${var.domains[0]}"
    "prometheus.ingress.tls"                                               = true
    "prometheus.persistence.enabled"                                       = true
    "prometheus.persistence.size"                                          = "10Gi"
    "prometheus.retention"                                                 = "10d" # How long to retain metrics TODO: set variables
    "prometheus.disableCompaction"                                         = true
    "prometheus.externalLabels.cluster"                                    = var.cluster_name
    "prometheus.thanos.create"                                             = true
    "prometheus.thanos.ingress.enabled"                                    = false # Need for external thanos
    "prometheus.thanos.ingress.certManager"                                = true
    "prometheus.thanos.ingress.hosts[0]"                                   = "thanos-gateway.${var.domains[0]}"
    "prometheus.thanos.ingress.tls[0].secretName"                          = "thanos-gateway-local-tls"
    "prometheus.thanos.ingress.tls[0].hosts[0]"                            = "thanos-gateway.${var.domains[0]}"
    "prometheus.thanos.objectStorageConfig.secretName"                     = local.storage > 0 ? kubernetes_secret.thanos_objstore[0].metadata[0].name : kubernetes_secret.s3_objstore[0].metadata[0].name
    "prometheus.thanos.objectStorageConfig.secretKey"                      = "objstore.yml"
    "prometheus.serviceAccount.name"                                       = local.thanos_name
    "prometheus.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.iam_assumable_role_admin.this_iam_role_arn
    "namespace"                                                            = local.namespace
  }
  prometheus_application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.prometheus_name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.prometheus_repository
        "targetRevision" = var.prometheus_chart_version
        "chart"          = local.prometheus_chart
        "helm" = {
          "parameters" = values({
            for key, value in local.prometheus_conf :
            key => {
              "name"  = key
              "value" = tostring(value)
            }
          })
        }
      }
      "syncPolicy" = {
        "syncOptions": [
        "Replace=true"
      ],
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }

  #Thanos
  thanos_name       = "thanos"
  thanos_repository = "https://charts.bitnami.com/bitnami"
  thanos_chart      = "thanos"
  thanos_conf       = merge(local.thanos_conf_defaults, var.thanos_conf)
  thanos_password   = var.thanos_password == "" ? random_password.thanos_password.result : var.thanos_password

  thanos_conf_defaults = {
    "query.sdConfig" = yamlencode(
      [{
        "targets" = ["kube-prometheus-prometheus-thanos:10901"] #//Change to variables (merge default with var)
      }]
    )
    "query.enabled"                     = "true"
    "query.ingress.enabled"             = "false"
    "query.ingress.grpc.enabled"        = "false"
    "queryFrontend.enabled"             = "true"
    "queryFrontend.ingress.enabled"     = "true"
    "queryFrontend.ingress.certManager" = "true"
    "queryFrontend.ingress.hostname"    = "thanos.${var.domains[0]}"
    "queryFrontend.ingress.tls"         = "true"
    "bucketweb.enabled"                 = "true"
    "compactor.enabled"                 = "true"
    "compactor.retentionResolutionRaw"  = "30d"
    "compactor.retentionResolution5m"   = "30d"
    "compactor.retentionResolution1h"   = "10y"
    "compactor.persistence.size"        = "10Gi"
    "storegateway.enabled"              = "true"
    "ruler.enabled"                     = "false"
    "receive.enabled"                   = "true"
    "metrics.enabled"                   = "true"
    "minio.enabled"                     = local.storage > 0 ? "true" : "false"
    "minio.accessKey.password"          = "thanosStorage"
    "minio.secretKey.password"          = local.storage > 0 ? "KMS_ENC:${aws_kms_ciphertext.thanos_password[0].ciphertext_blob}:" : ""
    "existingObjstoreSecret"            = local.storage > 0 ? kubernetes_secret.thanos_objstore[0].metadata[0].name : kubernetes_secret.s3_objstore[0].metadata[0].name
    "namespace"                         = local.namespace
    "existingServiceAccount"            = local.thanos_name # TODO: disable if local.prometheus_enabled = 0
  }
  thanos_application = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = local.thanos_name
      "namespace" = var.argocd.namespace
    }
    "spec" = {
      "destination" = {
        "namespace" = local.namespace
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "repoURL"        = local.thanos_repository
        "targetRevision" = var.thanos_chart_version
        "chart"          = local.thanos_chart
        "helm" = {
          "parameters" = values({
            for key, value in local.thanos_conf :
            key => {
              "name"  = key
              "value" = value
            }
          })
        }
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }
}
