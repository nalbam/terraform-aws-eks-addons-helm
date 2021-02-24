# argo-cd
# -> https://github.com/argoproj/argo-helm

resource "helm_release" "argo-cd" {
  count = var.argo_cd_enabled ? 1 : 0

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.helm_argo_cd

  namespace = "addon-argo-cd"
  name      = "argocd"

  values = [
    file("${path.module}/values/argo/argo-cd.yaml"),
    local.argocd_configs,
    local.argocd_ingress,
    local.argocd_metrics,
    var.argo_cd_apps_enabled ? local.argocd_apps : "",
    var.sso == "github" ? local.argocd_dex_github : "",
    var.sso == "google" ? local.argocd_oidc_google : "",
    var.sso == "okta" ? local.argocd_dex_okta : "",
  ]

  wait = false

  create_namespace = true

  # depends_on = [
  #   helm_release.prometheus-operator,
  # ]
}

resource "helm_release" "argocd-manager" {
  count = var.argo_cd_enabled ? 0 : 1

  repository = "https://charts.helm.sh/incubator"
  chart      = "raw"

  namespace = "kube-system"
  name      = "argocd-manager"

  values = [
    file("${path.module}/values/argo/argocd-manager.yaml")
  ]

  wait = false
}

resource "helm_release" "argocd-notifications" {
  count = var.argocd_notifications_enabled ? 1 : 0

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-notifications"
  version    = var.helm_argocd_notifications

  namespace = "addon-argo-cd"
  name      = "argocd-notifications"

  values = [
    file("${path.module}/values/argo/argocd-notifications.yaml"),
    local.argocd_notifications,
    local.argocd_notifications_config,
  ]

  create_namespace = true

  depends_on = [
    helm_release.argo-cd,
  ]
}

resource "helm_release" "argo-rollouts" {
  count = var.argo_rollouts_enabled ? 1 : 0

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  version    = "0.3.10" # var.helm_argo_rollouts # temp chart version
  # https://github.com/argoproj/argo-helm/issues/555

  namespace = "addon-argo-rollouts"
  name      = "argo-rollouts"

  values = [
    file("${path.module}/values/argo/argo-rollouts.yaml")
  ]

  create_namespace = true
}

resource "helm_release" "github-secret" {
  count = var.argo_cd_enabled ? var.external_secrets_enabled ? 1 : 0 : 0

  repository = "https://charts.helm.sh/incubator"
  chart      = "raw"

  namespace = "addon-argo-cd"
  name      = "github-secret"

  values = [
    file("${path.module}/values/argo/github-secret.yaml")
  ]

  wait = false

  depends_on = [
    helm_release.argo-cd,
    helm_release.external-secrets,
  ]
}

# resource "kubernetes_secret" "github-secret" {
#   count = var.argo_cd_enabled ? var.external_secrets_enabled ? 0 : 1 : 0

#   metadata {
#     namespace = "addon-argo-cd"
#     name      = "github-secret"
#   }

#   type = "Opaque"

#   data = {
#     "sshPrivateKey" = file("../../auth/github-secret.txt")
#   }

#   depends_on = [
#     helm_release.argo-cd,
#   ]
# }

locals {
  argocd_dex_callback = format("https://%s/api/dex/callback", local.argocd_host)

  # Argo expects the password in the secret to be bcrypt hashed.
  # You can create this hash with
  # `htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/'`
  # Password modification time defaults to current time if not set
  # argocdServerAdminPasswordMtime: "2006-01-02T15:04:05Z"
  # `date -u +"%Y-%m-%dT%H:%M:%SZ"`
  argocd_configs = yamlencode(
    {
      configs = {
        secret = {
          argocdServerAdminPassword      = data.aws_ssm_parameter.argocd_password.value
          argocdServerAdminPasswordMtime = data.aws_ssm_parameter.argocd_mtime.value
        }
      }
    }
  )

  argocd_ingress = yamlencode(
    {
      server = {
        "ingress" = {
          "enabled" = true
          "annotations" = {
            "kubernetes.io/ingress.class"              = var.ingress_class_http_public
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
          }
          "hosts" = [
            local.argocd_host
          ]
          "https" = false
        }
        "config" = {
          url = format("https://%s", local.argocd_host)
        }
      }
    }
  )

  argocd_metrics = yamlencode(
    {
      "server" = {
        metrics = {
          enabled = var.argo_cd_metrics_enabled
          serviceMonitor = {
            enabled = true
          }
        }
      }
      "repoServer" = {
        metrics = {
          enabled = var.argo_cd_metrics_enabled
          serviceMonitor = {
            enabled = true
          }
        }
      }
      "controller" = {
        metrics = {
          enabled = var.argo_cd_metrics_enabled
          serviceMonitor = {
            enabled = true
          }
        }
      }
      "dex" = {
        metrics = {
          enabled = var.argo_cd_metrics_enabled
          serviceMonitor = {
            enabled = true
          }
        }
      }
    }
  )

  argocd_apps = yamlencode(
    {
      server = {
        additionalApplications = [
          {
            "name"    = "apps"
            "project" = "default"
            "source" = {
              repoURL        = var.argo_cd_apps_repo_url
              targetRevision = var.argo_cd_apps_revision
              path           = var.argo_cd_apps_path
              directory = {
                recurse = true
              }
            }
            "destination" = {
              server    = "https://kubernetes.default.svc"
              namespace = "addon-argo-cd"
            }
            "syncPolicy" = {
              automated = {
                prune    = true
                selfHeal = true
              }
            }
          },
          # {
          #   "name"    = "apps-namespace"
          #   "project" = "default"
          #   "source" = {
          #     repoURL        = var.argo_cd_apps_repo_url
          #     targetRevision = var.argo_cd_apps_revision
          #     path           = var.argo_cd_apps_namespace
          #     directory = {
          #       recurse = true
          #     }
          #   }
          #   "destination" = {
          #     server    = "https://kubernetes.default.svc"
          #     namespace = "addon-argo-cd"
          #   }
          #   "syncPolicy" = {
          #     automated = {
          #       prune    = var.argo_cd_apps_automated
          #       selfHeal = var.argo_cd_apps_automated
          #     }
          #   }
          # },
        ]
      }
    }
  )

  argocd_dex_github = yamlencode(
    {
      server = {
        "config" = {
          "dex.config" = yamlencode(
            {
              connectors = [
                {
                  id   = "github"
                  type = "github"
                  name = "Github"
                  config = {
                    clientID     = data.aws_ssm_parameter.argocd_github_client_id.value
                    clientSecret = data.aws_ssm_parameter.argocd_github_client_secret.value
                    orgs = [
                      {
                        name  = var.sso_allowed_organizations
                        teams = []
                      }
                    ]
                  }
                }
              ]
            }
          )
        }
      }
    }
  )

  argocd_oidc_google = yamlencode(
    {
      server = {
        "config" = {
          "oidc.config" = yamlencode(
            {
              name   = "Google"
              issuer = "https://accounts.google.com"
              # clientID     = data.aws_ssm_parameter.google_client_id.value
              # clientSecret = data.aws_ssm_parameter.google_client_secret.value
              requestedScopes = [
                "https://www.googleapis.com/auth/userinfo.profile",
                "https://www.googleapis.com/auth/userinfo.email",
              ]
            }
          )
        }
        "rbacConfig" = {
          scopes = "[profile email]"
        }
      }
    }
  )

  argocd_dex_okta = yamlencode(
    {
      server = {
        "config" = {
          "dex.config" = yamlencode(
            {
              connectors = [
                {
                  id   = "okta"
                  type = "saml"
                  name = "Okta"
                  config = {
                    # # ca = "/path/to/ca.pem"
                    # caData = data.aws_ssm_parameter.argocd_okta_sign_key.value
                    # emailAttr = "email"
                    # groupsAttr = "group"
                    # redirectURI = local.argocd_dex_callback
                    # ssoURL = data.aws_ssm_parameter.argocd_okta_sign_url.value
                    # usernameAttr = "email"
                  }
                }
              ]
            }
          )
        }
        "rbacConfig" = {
          scopes = "[email,groups]"
        }
      }
    }
  )

  argocd_notifications = yamlencode(
    {
      "argocdUrl" = format("https://%s", local.argocd_host)
    }
  )

  argocd_notifications_config = data.template_file.argocd_notifications_config.rendered
}

data "template_file" "argocd_notifications_config" {
  template = file("${path.module}/templates/argocd_notifications.yaml.tpl")

  vars = {
    CLUSTER_NAME = local.cluster_name
    COUNTRY      = module.labels.country
    SLACK_TOKEN  = data.aws_ssm_parameter.argocd_noti_slack_token.value
  }
}
