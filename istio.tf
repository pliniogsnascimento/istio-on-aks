resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"

    labels = {
      "app" = "istio-system"
    }
  }
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  namespace  = kubernetes_namespace.istio-system.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"

  chart   = "base"
  version = "1.17.2"
}

resource "helm_release" "istio_discovery" {
  name       = "istiod"
  namespace  = kubernetes_namespace.istio-system.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"
  timeout    = 599

  chart   = "istiod"
  version = "1.17.2"
  values  = [file("${path.module}/manifests/values/istiod-values.yaml")]
  depends_on = [
    helm_release.istio_base
  ]
}

# resource "helm_release" "istio_ingress" {
#   name       = "istio-ingress"
#   namespace  = kubernetes_namespace.istio-system.metadata[0].name
#   repository = "https://istio-release.storage.googleapis.com/charts"
#   chart      = "gateway"
#   version    = "1.17.2"

#   values = [
#     <<EOF
# # Name allows overriding the release name. Generally this should not be set
# name: ""
# # revision declares which revision this gateway is a part of
# revision: ""

# replicaCount: 1

# kind: Deployment

# rbac:
#   # If enabled, roles will be created to enable accessing certificates from Gateways. This is not needed
#   # when using http://gateway-api.org/.
#   enabled: true

# serviceAccount:
#   # If set, a service account will be created. Otherwise, the default is used
#   create: true
#   # Annotations to add to the service account
#   annotations: {}
#   # The name of the service account to use.
#   # If not set, the release name is used
#   name: ""

# podAnnotations:
#   prometheus.io/port: "15020"
#   prometheus.io/scrape: "true"
#   prometheus.io/path: "/stats/prometheus"
#   inject.istio.io/templates: "gateway"
#   sidecar.istio.io/inject: "true"

# # Define the security context for the pod.
# # If unset, this will be automatically set to the minimum privileges required to bind to port 80 and 443.
# # On Kubernetes 1.22+, this only requires the `net.ipv4.ip_unprivileged_port_start` sysctl.
# securityContext: ~
# containerSecurityContext: ~

# service:
#   # Type of service. Set to "None" to disable the service entirely
#   type: LoadBalancer
#   ports:
#   - name: status-port
#     port: 15021
#     protocol: TCP
#     targetPort: 15021
#   - name: http2
#     port: 80
#     protocol: TCP
#     targetPort: 80
#   - name: https
#     port: 443
#     protocol: TCP
#     targetPort: 443
#   annotations: {}
#   loadBalancerIP: ""
#   loadBalancerSourceRanges: []
#   externalTrafficPolicy: ""
#   externalIPs: []

# resources:
#   requests:
#     cpu: 100m
#     memory: 128Mi
#   limits:
#     cpu: 2000m
#     memory: 1024Mi

# autoscaling:
#   enabled: true
#   minReplicas: 1
#   maxReplicas: 5
#   targetCPUUtilizationPercentage: 80

# # Pod environment variables
# env: {}

# # Labels to apply to all resources
# labels: {}

# # Annotations to apply to all resources
# annotations: {}

# nodeSelector: {}

# tolerations: []

# topologySpreadConstraints: []

# affinity: {}

# # If specified, the gateway will act as a network gateway for the given network.
# networkGateway: ""

# # Specify image pull policy if default behavior isn't desired.
# # Default behavior: latest images will be Always else IfNotPresent
# imagePullPolicy: ""

# imagePullSecrets: []
#   EOF
#   ]
#   depends_on = [
#     helm_release.istio_base,
#     helm_release.istio_discovery
#   ]
# }

resource "helm_release" "istio-ingressgw" {
  name      = "istio-ingressgw"
  namespace = kubernetes_namespace.istio-system.metadata[0].name
  chart     = "istio/manifests/charts/gateways/istio-ingress"
  values    = [file("${path.module}/manifests/values/istio-ingress-values.yaml")]
  timeout   = 598

  depends_on = [helm_release.istio_base, helm_release.istio_discovery]
}
