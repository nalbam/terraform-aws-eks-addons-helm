# data

data "aws_caller_identity" "current" {
}

data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

data "aws_ssm_parameter" "admin_username" {
  name = format("/k8s/%s/%s", var.cluster_env, "admin_username")
}

data "aws_ssm_parameter" "admin_password" {
  name = format("/k8s/%s/%s", var.cluster_env, "admin_password")
}

data "aws_ssm_parameter" "argocd_password" {
  name = format("/k8s/%s/%s", var.cluster_env, "argocd_password")
}

data "aws_ssm_parameter" "argocd_mtime" {
  name = format("/k8s/%s/%s", var.cluster_env, "argocd_mtime")
}

data "aws_ssm_parameter" "argocd_noti_username" {
  name = format("/k8s/%s/%s", var.cluster_env, "argocd_noti_username")
}

data "aws_ssm_parameter" "argocd_noti_slack_token" {
  name = format("/k8s/%s/%s", var.cluster_env, "argocd_noti_slack_token")
}

data "aws_ssm_parameter" "argocd_github_client_id" {
  name = format("/k8s/%s/%s/%s", var.cluster_env, local.cluster_name, "argocd/github_client_id")
}

data "aws_ssm_parameter" "argocd_github_client_secret" {
  name = format("/k8s/%s/%s/%s", var.cluster_env, local.cluster_name, "argocd/github_client_secret")
}

# data "aws_ssm_parameter" "argocd_okta_sign_url" {
#   name = format("/k8s/%s/%s/%s", var.cluster_env, local.cluster_name, "argocd/okta_sign_url")
# }

# data "aws_ssm_parameter" "argocd_okta_sign_key" {
#   name = format("/k8s/%s/%s/%s", var.cluster_env, local.cluster_name, "argocd/okta_sign_key")
# }

data "aws_ssm_parameter" "datadog_api_key" {
  name = format("/k8s/%s/%s", var.cluster_env, "datadog_api_key")
}

data "aws_ssm_parameter" "datadog_app_key" {
  name = format("/k8s/%s/%s", var.cluster_env, "datadog_app_key")
}

data "aws_ssm_parameter" "slack_token" {
  name = format("/k8s/%s/%s", var.cluster_env, "slack_token")
}
