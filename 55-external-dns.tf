# (DEPRECATED) external-dns

resource "helm_release" "external-dns" {
  count = var.external_dns_enabled ? 1 : 0

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = var.helm_external_dns

  namespace = "addon-external-dns"
  name      = "external-dns"

  values = [
    file("${path.module}/values/ingress/external-dns.yaml"),
    local.external_dns_values,
  ]

  wait = false

  create_namespace = true
}

locals {
  external_dns_role = format("arn:aws:iam::%s:role/irsa--%s--%s", local.account_id, local.cluster_group, "external-dns")

  external_dns_values = yamlencode(
    {
      "serviceAccount" = {
        "annotations" = {
          "eks.amazonaws.com/role-arn" = local.external_dns_role
        }
      }
    }
  )
}
