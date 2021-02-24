# dashboard
# -> https://github.com/kubernetes/dashboard/tree/master/aio/deploy/helm-chart/kubernetes-dashboard

resource "helm_release" "dashboard" {
  count = var.dashboard_enabled ? 1 : 0

  repository = "https://kubernetes.github.io/dashboard"
  chart      = "kubernetes-dashboard"
  version    = var.helm_kubernetes_dashboard

  namespace = "addon-dashboard"
  name      = "kubernetes-dashboard"

  values = [
    file("${path.module}/values/dashboard/dashboard.yaml"),
    local.dashboard_ingress,
  ]

  wait = false

  create_namespace = true
}

locals {
  dashboard_ingress = yamlencode(
    {
      ingress = {
        "enabled" = true
        "annotations" = {
          "kubernetes.io/ingress.class"              = var.ingress_class_http_internal
          "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
        }
        "hosts" = [
          local.dashboard_host
        ]
      }
    }
  )
}

resource "helm_release" "dashboard-rbac" {
  count = var.dashboard_enabled ? 1 : 0

  repository = "https://charts.helm.sh/incubator"
  chart      = "raw"

  namespace = "addon-dashboard"
  name      = "kubernetes-dashboard-rbac"

  values = [
    file("${path.module}/values/dashboard/dashboard-rbac.yaml")
  ]

  wait = false

  create_namespace = true
}
