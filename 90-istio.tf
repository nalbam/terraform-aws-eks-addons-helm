# istio
# MUST install istio-operator
# SEE: https://github.com/daangn/hoian-env/tree/main/istio

resource "helm_release" "istio" {
  count = var.istio_enabled ? 1 : 0

  repository = "https://charts.helm.sh/incubator"
  chart      = "raw"

  namespace = "istio-system"
  name      = "istio"

  values = [
    file("${path.module}/values/istio/istio-operator.yaml")
  ]

  create_namespace = true

  wait = false
}

resource "helm_release" "istio_certificate_krmt" {
  count = var.cert_manager_enabled ? 1 : 0

  # repository = data.helm_repository.incubator.metadata.0.name
  repository = "https://charts.helm.sh/incubator"
  chart      = "raw"

  namespace = "istio-system"
  name      = "krmt-ss-cert"

  values = [
    # file("${path.module}/values/istio/certificate-krmt-ss-cert.yaml"),
    data.template_file.istio_certificate_krmt.rendered,
  ]

  wait = false

  create_namespace = true

  depends_on = [
    helm_release.cert-manager,
  ]
}

locals {
  kiali_host   = format("kiali.%s", local.domain_internal)
  tracing_host = format("tracing.%s", local.domain_internal)
}

resource "kubernetes_ingress" "istio-kiali" {
  count = var.istio_kiali_enabled ? 1 : 0

  metadata {
    namespace = "istio-system"
    name      = "kiali"
    annotations = {
      "kubernetes.io/ingress.class"              = var.ingress_class_http_internal
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    rule {
      host = local.kiali_host
      http {
        path {
          backend {
            service_name = "kiali"
            service_port = 20001
          }
          path = "/"
        }
      }
    }
  }
}

resource "kubernetes_ingress" "istio-tracing" {
  count = var.istio_tracing_enabled ? 1 : 0

  metadata {
    namespace = "istio-system"
    name      = "tracing"
    annotations = {
      "kubernetes.io/ingress.class"              = var.ingress_class_http_internal
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    rule {
      host = local.tracing_host
      http {
        path {
          backend {
            service_name = "tracing"
            service_port = 16686
          }
          path = "/"
        }
      }
    }
  }
}

data "template_file" "istio_certificate_krmt" {
  template = file("${path.module}/templates/istio_certificate_krmt.yaml.tpl")

  vars = {
    COUNTRY = module.labels.region_domain
  }
}
