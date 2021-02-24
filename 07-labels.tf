# labels

module labels {
  source = "git@github.com:daangn/terraform-aws-labels.git?ref=v0.1.4"

  region  = var.region
  env     = var.cluster_env
  role    = var.cluster_role
  service = var.cluster_service
  team    = var.cluster_team
}
