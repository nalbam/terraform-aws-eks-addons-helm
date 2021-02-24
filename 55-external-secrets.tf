# external-secrets
# -> https://github.com/external-secrets/kubernetes-external-secrets

resource "helm_release" "external-secrets" {
  count = var.external_secrets_enabled ? 1 : 0

  repository = "https://external-secrets.github.io/kubernetes-external-secrets"
  chart      = "kubernetes-external-secrets"
  version    = var.helm_kubernetes_external_secrets

  namespace = "addon-external-secrets"
  name      = "external-secrets"

  values = [
    file("${path.module}/values/secrets/external-secrets.yaml"),
    local.external_secrets_values,
  ]

  create_namespace = true
}

locals {
  external_secrets_role = format("arn:aws:iam::%s:role/irsa--%s--%s", local.account_id, local.cluster_group, "external-secrets")

  external_secrets_values = yamlencode(
    {
      "env" = {
        "AWS_REGION" = var.region
      }
      "serviceAccount" = {
        "annotations" = {
          "eks.amazonaws.com/role-arn" = local.external_secrets_role
        }
      }
    }
  )
}
