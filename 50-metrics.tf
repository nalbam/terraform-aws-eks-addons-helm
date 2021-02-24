# metrics

resource "helm_release" "metrics-server" {
  repository = "https://charts.helm.sh/stable"
  chart      = "metrics-server"
  version    = var.helm_metrics_server

  namespace = "addon-metrics"
  name      = "metrics-server"

  values = [
    file("${path.module}/values/metrics/metrics-server.yaml")
  ]

  wait = false

  create_namespace = true
}
