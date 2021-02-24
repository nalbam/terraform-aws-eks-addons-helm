# (DEPRECATED) cluster-overprovisioner
# -> https://github.com/deliveryhero/helm-charts

resource "helm_release" "cluster-overprovisioner" {
  count = var.cluster_overprovisioner_replicas > 0 ? 1 : 0

  repository = "https://charts.deliveryhero.io"
  chart      = "cluster-overprovisioner"
  version    = var.helm_cluster_overprovisioner

  namespace = "addon-cluster-overprovisioner"
  name      = "cluster-overprovisioner"

  values = [
    file("${path.module}/values/autoscale/cluster-overprovisioner.yaml"),
    local.cluster_overprovisioner_values,
  ]

  wait = false

  create_namespace = true
}

locals {
  cluster_overprovisioner_values = yamlencode(
    {
      deployments = [
        {
          "name"         = "default"
          "replicaCount" = var.cluster_overprovisioner_replicas
          "resources" = {
            "requests" = {
              cpu    = "2"
              memory = "2Gi"
            }
            "limits" = {
              cpu    = "2"
              memory = "2Gi"
            }
          }
        }
      ]
    }
  )
}
