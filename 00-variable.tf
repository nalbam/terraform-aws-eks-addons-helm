# variable

variable "region" {
  default = "ap-northeast-2"
}

variable "cluster_env" {
  default = "alpha" # [alpha, prod]
}

variable "cluster_suffix" {
  default = "a" # [a, b]
}

variable "cluster_role" {
  default = "eks"
}

variable "cluster_service" {
  default = "ks"
}

variable "cluster_team" {
  default = "platform"
}

variable "root_domain_internal" {
  description = "내부용 루트 도메인 주소를 입력 합니다."
  default     = "krmt.io"
}

variable "root_domain_public" {
  description = "공개용 루트 도메인 주소를 입력 합니다."
  default     = "karrotmarket.com"
}

variable "storage_class_name" {
  default = "gp2"
}

### sso ###

variable "sso" {
  default = "github" # [github, google, okta]
}

variable "sso_allowed_domains" {
  default = "daangn.com" # for google
}

variable "sso_allowed_organizations" {
  default = "daangn" # for github
}

## ingress ##

variable "aws_load_balancer_enabled" {
  default = false
}

variable "aws_load_balancer_tgbs" {
  default = []
}

variable "ingress_nginx_http_internal" {
  default = 0
}

variable "ingress_nginx_http_public" {
  default = 0
}

variable "ingress_class_http_internal" {
  default = "nginx-internal"
}

variable "ingress_class_http_public" {
  default = "nginx-public"
}

### monitor ###

variable "datadog_enabled" {
  default = false
}

variable "dashboard_enabled" {
  default = false
}

variable "grafana_enabled" {
  default = false
}

variable "promtail_enabled" {
  default = false
}

variable "prometheus_enabled" {
  default = false
}

### cd ###

variable "argo_cd_enabled" {
  default = false
}

variable "argo_cd_apps_enabled" {
  default = false
}

variable "argo_cd_metrics_enabled" {
  default = true
}

variable "argo_cd_apps_repo_url" {
  default = "git@github.com:daangn/hoian-eks.git"
}

variable "argo_cd_apps_revision" {
  default = "master"
}

variable "argo_cd_apps_path" {
  default = "release/_apps"
}

variable "argocd_notifications_enabled" {
  default = false
}

variable "argo_rollouts_enabled" {
  default = false
}

variable "fluxcd_enabled" {
  default = false
}

variable "gocd_enabled" {
  default = false
}

### operator ###

variable "cluster_autoscaler_min_cpu" {
  default = "0.6"
}

variable "cluster_overprovisioner_replicas" {
  default = "0"
}

variable "chaoskube_enabled" {
  default = false
}

variable "cert_manager_enabled" {
  default = false
}

variable "external_dns_enabled" {
  default = false
}

variable "external_secrets_enabled" {
  default = false
}

variable "istio_enabled" {
  default = false
}

variable "istio_kiali_enabled" {
  default = false
}

variable "istio_tracing_enabled" {
  default = false
}
