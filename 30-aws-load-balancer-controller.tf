# addon-ingress
# -> https://github.com/aws/eks-charts

resource "helm_release" "aws-load-balancer-controller" {
  count = var.aws_load_balancer_enabled ? 1 : 0

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.helm_aws_load_balancer_controller

  namespace = "addon-aws-load-balancer-controller"
  name      = "aws-load-balancer-controller"

  values = [
    file("${path.module}/values/ingress/aws-load-balancer-controller.yaml"),
    local.aws_load_balancer_controller_values,
  ]

  wait = false

  create_namespace = true
}

locals {
  aws_load_balancer_controller_role = format("arn:aws:iam::%s:role/irsa--%s--%s", local.account_id, local.cluster_group, "aws-load-balancer-controller")

  aws_load_balancer_controller_values = yamlencode(
    {
      "clusterName" = local.cluster_name
      "serviceAccount" = {
        "annotations" = {
          "eks.amazonaws.com/role-arn" = local.aws_load_balancer_controller_role
        }
      }
    }
  )
}

resource "helm_release" "aws-load-balancer-tgbs" {
  count = var.aws_load_balancer_enabled ? length(var.aws_load_balancer_tgbs) : 0

  repository = "https://charts.helm.sh/incubator"
  chart      = "raw"

  namespace = var.aws_load_balancer_tgbs[count.index].namespace
  name      = var.aws_load_balancer_tgbs[count.index].name

  values = [
    # file("${path.module}/values/ingress/tgbs.yaml"),
    yamlencode(
      {
        "resources" = [
          {
            "apiVersion" = "elbv2.k8s.aws/v1beta1"
            "kind" = "TargetGroupBinding"
            "metadata" = {
              "name" = var.aws_load_balancer_tgbs[count.index].name
              "namespace" = var.aws_load_balancer_tgbs[count.index].namespace
            }
            "spec" = {
              "serviceRef" = {
                "name" = var.aws_load_balancer_tgbs[count.index].service_name
                "port" = var.aws_load_balancer_tgbs[count.index].service_port
              }
              "targetGroupARN" = var.aws_load_balancer_tgbs[count.index].targt_group_arn
              "targetType" = var.aws_load_balancer_tgbs[count.index].target_type
            }
          }
        ]
      }
    )
  ]

  wait = false

  create_namespace = true

  depends_on = [
    helm_release.aws-load-balancer-controller,
  ]
}
