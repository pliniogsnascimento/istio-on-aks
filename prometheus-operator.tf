resource "helm_release" "prometheus-operator" {
  name             = "prometheus-operator"
  namespace        = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  create_namespace = true
  version          = "45.25.0"

  values = [ file("${path.module}/manifests/values/prometheus-operator.yaml") ]
}
