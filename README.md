# terraform-aws-eks-addons

<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| helm | n/a |
| kubernetes | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| argo\_cd\_apps\_enabled | n/a | `bool` | `false` | no |
| argo\_cd\_apps\_path | n/a | `string` | `"release/_apps"` | no |
| argo\_cd\_apps\_repo\_url | n/a | `string` | `"git@github.com:daangn/hoian-eks.git"` | no |
| argo\_cd\_apps\_revision | n/a | `string` | `"master"` | no |
| argo\_cd\_enabled | n/a | `bool` | `false` | no |
| argo\_cd\_metrics\_enabled | n/a | `bool` | `true` | no |
| argo\_rollouts\_enabled | n/a | `bool` | `false` | no |
| argocd\_notifications\_enabled | n/a | `bool` | `false` | no |
| aws\_load\_balancer\_enabled | n/a | `bool` | `false` | no |
| aws\_load\_balancer\_tgbs | n/a | `list` | `[]` | no |
| cert\_manager\_enabled | n/a | `bool` | `false` | no |
| chaoskube\_enabled | n/a | `bool` | `false` | no |
| cluster\_autoscaler\_min\_cpu | n/a | `string` | `"0.6"` | no |
| cluster\_env | n/a | `string` | `"alpha"` | no |
| cluster\_overprovisioner\_replicas | n/a | `string` | `"0"` | no |
| cluster\_role | n/a | `string` | `"eks"` | no |
| cluster\_service | n/a | `string` | `"ks"` | no |
| cluster\_suffix | n/a | `string` | `"a"` | no |
| cluster\_team | n/a | `string` | `"platform"` | no |
| dashboard\_enabled | n/a | `bool` | `false` | no |
| datadog\_enabled | n/a | `bool` | `false` | no |
| external\_dns\_enabled | n/a | `bool` | `false` | no |
| external\_secrets\_enabled | n/a | `bool` | `false` | no |
| fluxcd\_enabled | n/a | `bool` | `false` | no |
| gocd\_enabled | n/a | `bool` | `false` | no |
| grafana\_enabled | n/a | `bool` | `false` | no |
| helm\_argo\_cd | argo/argo-cd | `string` | `"2.14.7"` | no |
| helm\_argo\_rollouts | argo/argo-rollouts | `string` | `"0.4.3"` | no |
| helm\_argocd\_notifications | argo/argocd-notifications | `string` | `"1.0.14"` | no |
| helm\_aws\_load\_balancer\_controller | eks/aws-load-balancer-controller | `string` | `"1.1.5"` | no |
| helm\_cert\_manager | jetstack/cert-manager | `string` | `"v1.2.0"` | no |
| helm\_chaoskube | stable/chaoskube | `string` | `"3.3.2"` | no |
| helm\_cluster\_autoscaler | autoscaler/cluster-autoscaler | `string` | `"9.4.0"` | no |
| helm\_cluster\_overprovisioner | deliveryhero/cluster-overprovisioner | `string` | `"0.5.0"` | no |
| helm\_datadog | datadog/datadog | `string` | `"2.9.0"` | no |
| helm\_external\_dns | bitnami/external-dns | `string` | `"4.8.3"` | no |
| helm\_fluxcd\_flux | fluxcd/flux | `string` | `"1.6.2"` | no |
| helm\_gocd | gocd/gocd | `string` | `"1.36.0"` | no |
| helm\_grafana | grafana/grafana | `string` | `"6.4.4"` | no |
| helm\_ingress\_nginx | ingress-nginx/ingress-nginx | `string` | `"3.23.0"` | no |
| helm\_kube\_prometheus\_stack | prometheus/kube-prometheus-stack | `string` | `"13.13.0"` | no |
| helm\_kubernetes\_dashboard | dashboard/kubernetes-dashboard | `string` | `"4.0.2"` | no |
| helm\_kubernetes\_external\_secrets | external-secrets/kubernetes-external-secrets | `string` | `"6.3.0"` | no |
| helm\_metrics\_server | stable/metrics-server | `string` | `"2.11.4"` | no |
| helm\_prometheus\_adapter | prometheus/prometheus-adapter | `string` | `"2.12.1"` | no |
| helm\_promtail | grafana/promtail | `string` | `"3.1.0"` | no |
| ingress\_class\_http\_internal | n/a | `string` | `"nginx-internal"` | no |
| ingress\_class\_http\_public | n/a | `string` | `"nginx-public"` | no |
| ingress\_nginx\_http\_internal | n/a | `number` | `0` | no |
| ingress\_nginx\_http\_public | n/a | `number` | `0` | no |
| istio\_enabled | n/a | `bool` | `false` | no |
| istio\_kiali\_enabled | n/a | `bool` | `false` | no |
| istio\_tracing\_enabled | n/a | `bool` | `false` | no |
| prometheus\_enabled | n/a | `bool` | `false` | no |
| promtail\_enabled | n/a | `bool` | `false` | no |
| region | n/a | `string` | `"ap-northeast-2"` | no |
| root\_domain\_internal | 내부용 루트 도메인 주소를 입력 합니다. | `string` | `"krmt.io"` | no |
| root\_domain\_public | 공개용 루트 도메인 주소를 입력 합니다. | `string` | `"karrotmarket.com"` | no |
| sso | n/a | `string` | `"github"` | no |
| sso\_allowed\_domains | n/a | `string` | `"daangn.com"` | no |
| sso\_allowed\_organizations | n/a | `string` | `"daangn"` | no |
| storage\_class\_name | n/a | `string` | `"gp2"` | no |

## Outputs

No output.

<!--- END_TF_DOCS --->

## Helm Repos

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add dashboard https://kubernetes.github.io/dashboard
helm repo add datadog https://helm.datadoghq.com
helm repo add deliveryhero https://charts.deliveryhero.io
helm repo add eks https://aws.github.io/eks-charts
helm repo add external-secrets https://external-secrets.github.io/kubernetes-external-secrets
helm repo add fluxcd https://charts.fluxcd.io
helm repo add gocd https://gocd.github.io/helm-chart
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add incubator https://charts.helm.sh/incubator
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo add prometheus https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
```
