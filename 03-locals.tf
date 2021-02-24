# locals

locals {
  account_id = data.aws_caller_identity.current.account_id
}

locals {
  # alpha, prod-ks
  group_name = var.cluster_env == "alpha" ? var.cluster_env : format("%s-%s", var.cluster_env, var.cluster_service)

  # alpha-kr, prod-ks-kr
  cluster_group = format("%s-%s", local.group_name, module.labels.country)

  # alpha-kr-x, prod-ks-kr-x
  cluster_name = format("%s-%s-%s", local.group_name, module.labels.country, var.cluster_suffix)

  sub_name   = var.cluster_env == "alpha" ? var.cluster_env : var.cluster_service
  sub_domain = format("%s-%s.%s", local.sub_name, var.cluster_suffix, module.labels.region_domain)

  domain_internal = format("%s.%s", local.sub_domain, var.root_domain_internal)
  domain_public   = format("%s.%s", local.sub_domain, var.root_domain_public)
}

locals {
  argocd_host     = format("argocd.%s", local.domain_public)
  dashboard_host  = format("dashboard.%s", local.domain_internal)
  gocd_host       = format("gocd.%s", local.domain_internal)
  grafana_host    = format("grafana.%s", local.domain_internal)
  prometheus_host = format("prometheus.%s", local.domain_internal)
}

locals {
  admin_username = data.aws_ssm_parameter.admin_username.value
  admin_password = data.aws_ssm_parameter.admin_password.value

  slack_token = data.aws_ssm_parameter.slack_token.value
  slack_url   = format("https://hooks.slack.com/services/%s", local.slack_token)
}

locals {
  tags = {
    "KubernetesCluster"                           = local.cluster_name
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}
