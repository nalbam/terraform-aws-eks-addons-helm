# datadog
# -> https://github.com/DataDog/helm-charts

resource "helm_release" "datadog" {
  count = var.datadog_enabled ? 1 : 0

  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  version    = var.helm_datadog

  namespace = "addon-datadog"
  name      = "datadog"

  values = [
    file("${path.module}/values/datadog/datadog.yaml"),
    local.datadog_values,
  ]

  wait = false

  create_namespace = true
}

locals {
  datadog_tags = format("cluster_name:%s country_code:%s env:%s-%s", local.cluster_name, module.labels.country, var.cluster_env, module.labels.country)

  datadog_values = yamlencode(
    {
      datadog = {
        clusterName = local.cluster_name
        apiKey      = data.aws_ssm_parameter.datadog_api_key.value
        appKey      = data.aws_ssm_parameter.datadog_app_key.value
        env = [
          {
            name  = "DD_TAGS"
            value = local.datadog_tags
          },
          {
            name = "DD_AGENT_HOST"
            valueFrom = {
              fieldRef = {
                fieldPath = "status.hostIP"
              }
            }
          },
        ]
      }
    }
  )
}
