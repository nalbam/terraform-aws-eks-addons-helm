# addon-ingress (standalone http internal)
# -> https://github.com/kubernetes/ingress-nginx

resource "helm_release" "ingress-nginx-http-internal" {
  count = var.ingress_nginx_http_internal > 0 ? 1 : 0

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.helm_ingress_nginx

  namespace = "addon-ingress-nginx-http-internal"
  name      = "ingress-nginx-http-internal"

  values = [
    file("${path.module}/values/ingress/ingress-nginx-http.yaml"),
    local.ingress_nginx_http_internal,
  ]

  wait = false

  create_namespace = true

  # depends_on = [
  #   helm_release.prometheus-operator,
  # ]
}

locals {
  ingress_nginx_http_internal = yamlencode(
    {
      "nameOverride" = "ingress-nginx-http-internal"
      "controller" = {
        "kind" = "DaemonSet"
        # "replicaCount" = var.ingress_nginx_http_internal
        # "autoscaling" = {
        #   enabled     = true
        #   minReplicas = var.ingress_nginx_http_internal
        #   maxReplicas = 30
        # }
        "config" = {
          "whitelist-source-range" = "10.0.0.0/8"
        }
        "ingressClass" = var.ingress_class_http_internal
        "service" = {
          "type" = "NodePort"
          "nodePorts" = {
            "http"  = 31080
            "https" = 31443
            "tcp" = {
              "8200" = 31200
            }
          }
          # "healthCheckNodePort" = 31200
          "externalTrafficPolicy" = "Local"
          "internal" = {
            "enabled" = true
          }
        }
        "metrics" = {
          "serviceMonitor" = {
            "enabled" = true
          }
        }
      }
      tcp = {
        "8200" = "addon-ingress-nginx-http-internal/ingress-nginx-http-internal-default-backend:80"
      }
    }
  )
}
