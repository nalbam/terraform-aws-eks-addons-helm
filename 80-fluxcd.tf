# fluxcd
# -> https://github.com/fluxcd/charts

resource "helm_release" "fluxcd" {
  count = var.fluxcd_enabled ? 1 : 0

  repository = "https://fluxcd.github.io/helm-chart"
  chart      = "flux"
  version    = var.helm_fluxcd_flux

  namespace = "addon-fluxcd"
  name      = "fluxcd"

  values = [
    file("${path.module}/values/fluxcd/fluxcd.yaml")
  ]

  wait = false

  create_namespace = true

  # depends_on = [
  #   helm_release.prometheus-operator,
  # ]
}
