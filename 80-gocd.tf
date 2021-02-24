# gocd
# -> https://github.com/gocd/helm-chart

resource "helm_release" "gocd" {
  count = var.gocd_enabled ? 1 : 0

  repository = "https://gocd.github.io/helm-chart"
  chart      = "gocd"
  version    = var.helm_gocd

  namespace = "addon-gocd"
  name      = "gocd"

  values = [
    file("${path.module}/values/gocd/gocd.yaml"),
    local.gocd_ingress,
  ]

  wait = false

  create_namespace = true

  # depends_on = [
  #   helm_release.prometheus-operator,
  # ]
}

locals {
  gocd_ingress = yamlencode(
    {
      server = {
        "ingress" = {
          "enabled" = true
          "annotations" = {
            "kubernetes.io/ingress.class"              = var.ingress_class_http_internal
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
          }
          "hosts" = [
            local.gocd_host
          ]
        }
        "persistence" = {
          storageClassName = var.storage_class_name
          size = "10Gi"
        }
      }
    }
  )
}
