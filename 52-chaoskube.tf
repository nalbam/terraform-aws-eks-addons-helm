# chaoskube

resource "helm_release" "chaoskube" {
  count = var.chaoskube_enabled ? 1 : 0

  repository = "https://charts.helm.sh/stable"
  chart      = "chaoskube"
  version    = var.helm_chaoskube

  namespace = "addon-chaoskube"
  name      = "chaoskube"

  values = [
    file("${path.module}/values/chaos/chaoskube.yaml")
  ]

  wait = false

  create_namespace = true
}
