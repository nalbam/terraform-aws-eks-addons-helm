# addon-ingress (standalone http internal)
# -> https://github.com/kubernetes/ingress-nginx

resource "helm_release" "ingress-nginx-http-public" {
  count = var.ingress_nginx_http_public > 0 ? 1 : 0

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.helm_ingress_nginx

  namespace = "addon-ingress-nginx-http-public"
  name      = "ingress-nginx-http-public"

  values = [
    file("${path.module}/values/ingress/ingress-nginx-http.yaml"),
    local.ingress_nginx_http_public,
  ]

  wait = false

  create_namespace = true

  # depends_on = [
  #   helm_release.prometheus-operator,
  # ]
}

locals {
  ingress_nginx_http_public = yamlencode(
    {
      "nameOverride" = "ingress-nginx-http-public"
      "controller" = {
        "kind" = "DaemonSet"
        # "replicaCount" = var.ingress_nginx_http_public
        # "autoscaling" = {
        #   enabled     = true
        #   minReplicas = var.ingress_nginx_http_public
        #   maxReplicas = 50
        # }
        "ingressClass" = var.ingress_class_http_public
        "service" = {
          "type" = "NodePort"
          "nodePorts" = {
            "http"  = 30080
            "https" = 30443
            "tcp" = {
              "8200" = 30200
            }
          }
          # "healthCheckNodePort" = 30200
          "externalTrafficPolicy" = "Local"
          # "internal" = {
          #   "enabled" = false
          # }
        }
        "metrics" = {
          "serviceMonitor" = {
            "enabled" = true
          }
        }
      }
      tcp = {
        "8200" = "addon-ingress-nginx-http-public/ingress-nginx-http-public-default-backend:80"
      }
    }
  )
}
