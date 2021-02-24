# (DEPRECATED) grafana
# -> https://github.com/grafana/helm-charts

resource "helm_release" "grafana" {
  count = var.grafana_enabled ? 1 : 0

  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.helm_grafana

  namespace = "addon-grafana"
  name      = "grafana"

  values = [
    file("${path.module}/values/grafana/grafana.yaml"),
    local.grafana_configs,
    local.grafana_ingress,
    var.sso == "github" ? local.grafana_auth_github : "",
    var.sso == "google" ? local.grafana_auth_google : "",
  ]

  wait = false

  create_namespace = true
}

locals {
  grafana_configs = yamlencode(
    {
      "adminUser"     = local.admin_username
      "adminPassword" = local.admin_password
      "grafana.ini" = {
        auth = {
          disable_login_form = var.sso == "" ? false : true
        }
      }
      "persistence" = {
        storageClassName = var.storage_class_name
        size = "10Gi"
      }
    }
  )

  grafana_ingress = yamlencode(
    {
      ingress = {
        "enabled" = true
        "annotations" = {
          "kubernetes.io/ingress.class"              = var.ingress_class_http_internal
          "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
        }
        "hosts" = [
          local.grafana_host
        ]
      }
      "grafana.ini" = {
        server = {
          root_url = format("https://%s/", local.grafana_host)
        }
      }
    }
  )

  grafana_auth_google = yamlencode(
    {
      "grafana.ini" = {
        "auth.google" = {
          enabled = true
          # client_id       = data.aws_ssm_parameter.google_client_id.value
          # client_secret   = data.aws_ssm_parameter.google_client_secret.value
          allowed_domains = var.sso_allowed_domains
        }
      }
    }
  )

  grafana_auth_github = yamlencode(
    {
      "grafana.ini" = {
        "auth.github" = {
          enabled = true
          # client_id             = data.aws_ssm_parameter.grafana_github_client_id.value
          # client_secret         = data.aws_ssm_parameter.grafana_github_client_secret.value
          allowed_organizations = var.sso_allowed_organizations
          team_ids              = ""
        }
      }
    }
  )
}
