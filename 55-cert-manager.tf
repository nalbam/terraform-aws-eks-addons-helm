# cert-manager

resource "helm_release" "cert-manager" {
  count = var.cert_manager_enabled ? 1 : 0

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.helm_cert_manager

  namespace = "addon-cert-manager"
  name      = "cert-manager"

  values = [
    file("${path.module}/values/cert/cert-manager.yaml")
  ]

  create_namespace = true

  # depends_on = [
  #   helm_release.prometheus-operator,
  # ]
}

resource "helm_release" "cert-manager-issuers-self" {
  count = var.cert_manager_enabled ? 1 : 0

  # repository = data.helm_repository.incubator.metadata.0.name
  repository = "https://charts.helm.sh/incubator"
  chart      = "raw"

  namespace = "addon-cert-manager"
  name      = "cluster-issuer-selfsigned"

  values = [
    file("${path.module}/values/cert/cluster-issuer-selfsigned.yaml")
  ]

  wait = false

  create_namespace = true

  depends_on = [
    helm_release.cert-manager,
  ]
}

# resource "helm_release" "cert-manager-issuers" {
#   count = var.cert_manager_enabled ? 1 : 0

#   # repository = data.helm_repository.incubator.metadata.0.name
#   repository = "https://charts.helm.sh/incubator"
#   chart      = "raw"

#   namespace = "addon-cert-manager"
#   name      = "cluster-issuer"

#   values = [
#     file("${path.module}/values/cert/cluster-issuer.yaml")
#   ]

#   wait = false

#   create_namespace = true

#   depends_on = [
#     helm_release.cert-manager,
#   ]
# }
