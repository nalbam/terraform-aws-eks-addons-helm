# (DEPRECATED) promtail
# -> https://github.com/grafana/helm-charts

resource "helm_release" "promtail" {
  count = var.promtail_enabled ? 1 : 0

  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = var.helm_promtail

  namespace = "addon-promtail"
  name      = "promtail"

  values = [
    file("${path.module}/values/promtail/promtail.yaml")
  ]

  wait = false

  create_namespace = true
}
