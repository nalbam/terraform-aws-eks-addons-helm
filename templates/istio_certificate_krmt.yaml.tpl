resources:
  - apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: krmt-ss-cert
    spec:
      commonName: krmt.io
      dnsNames:
        - "*.krmt.io"
        - "*.${COUNTRY}.krmt.io"
        - "*.alpha.${COUNTRY}.krmt.io"
      secretName: "krmt-ss-cert"
      duration: "87600h"
      renewBefore: "70080h"
      issuerRef:
        kind: "ClusterIssuer"
        name: "cluster-issuer-selfsigned"
