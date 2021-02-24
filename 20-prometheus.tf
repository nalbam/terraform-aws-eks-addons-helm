# prometheus
# -> https://github.com/prometheus-community/helm-charts

resource "helm_release" "kube-prometheus-stack" {
  count = var.prometheus_enabled ? 1 : 0

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.helm_kube_prometheus_stack

  namespace = "addon-prometheus"
  name      = "kube-prometheus-stack"

  values = [
    file("${path.module}/values/prometheus/kube-prometheus-stack.yaml"),
    local.prometheus_values,
    local.prometheus_grafana,
    local.prometheus_alertmanager,
  ]

  create_namespace = true
}

resource "helm_release" "prometheus-adapter" {
  count = var.prometheus_enabled ? 1 : 0

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-adapter"
  version    = "2.8.1" # var.helm_prometheus_adapter # temp chart version
  # https://github.com/external-secrets/kubernetes-external-secrets/issues/563

  namespace = "addon-prometheus"
  name      = "prometheus-adapter"

  values = [
    file("${path.module}/values/prometheus/prometheus-adapter.yaml")
  ]

  wait = false

  create_namespace = true

  depends_on = [
    helm_release.kube-prometheus-stack,
  ]
}

resource "helm_release" "prometheus-alert-rules" {
  count = var.prometheus_enabled ? 1 : 0

  repository = "https://charts.helm.sh/incubator"
  chart      = "raw"

  namespace = "addon-prometheus"
  name      = "prometheus-alert-rules"

  values = [
    file("${path.module}/values/prometheus/prometheus-alert-rules.yaml")
  ]

  wait = false

  create_namespace = true

  depends_on = [
    helm_release.kube-prometheus-stack,
  ]
}

locals {
  prometheus_values = yamlencode(
    {
      "prometheus" = {
        "ingress" = {
          "enabled" = true
          "annotations" = {
            "kubernetes.io/ingress.class"              = var.ingress_class_http_internal
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
          }
          "hosts" = [
            local.prometheus_host
          ]
        }
        "prometheusSpec" = {
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.storage_class_name
                resources = {
                  requests = {
                    storage = "100Gi"
                  }
                }
              }
            }
          }
        }
      }
    }
  )

  prometheus_grafana = yamlencode(
    {
      "grafana" = {
        "enabled" = var.grafana_enabled ? false : true
        "adminPassword" = local.admin_password
        "ingress" = {
          "enabled" = true
          "annotations" = {
            "kubernetes.io/ingress.class"              = var.ingress_class_http_internal
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
          }
          "hosts" = [
            local.grafana_host
          ]
        }
      }
    }
  )

  prometheus_alertmanager = data.template_file.alertmanager_config.rendered
}

data "template_file" "alertmanager_config" {
  template = file("${path.module}/templates/alertmanager_config.yaml.tpl")

  vars = {
    CLUSTER_NAME  = local.cluster_name
    COUNTRY       = module.labels.country
    SLACK_API_URL = local.slack_url
    SLACK_CHANNEL = format("#noti-k8s-%s", local.cluster_group)
  }
}
