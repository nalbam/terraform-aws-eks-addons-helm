# cluster-autoscaler
# -> https://github.com/kubernetes/autoscaler

resource "helm_release" "cluster-autoscaler" {
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = var.helm_cluster_autoscaler

  namespace = "addon-cluster-autoscaler"
  name      = "cluster-autoscaler"

  values = [
    file("${path.module}/values/autoscale/cluster-autoscaler.yaml"),
    local.cluster_autoscaler_values,
  ]

  wait = false

  create_namespace = true

  # depends_on = [
  #   helm_release.prometheus-operator,
  # ]
}

locals {
  cluster_autoscaler_role = format("arn:aws:iam::%s:role/irsa--%s--%s", local.account_id, local.cluster_group, "cluster-autoscaler")

  cluster_autoscaler_values = yamlencode(
    {
      "awsRegion" = var.region
      "autoDiscovery" = {
        "clusterName" = local.cluster_name
      }
      "extraArgs" = {
        "scale-down-utilization-threshold" = var.cluster_autoscaler_min_cpu
      }
      "rbac" = {
        "serviceAccount" = {
          "annotations" = {
            "eks.amazonaws.com/role-arn" = local.cluster_autoscaler_role
          }
        }
      }
      "serviceMonitor" = {
        "enabled" = true
      }
    }
  )
}
