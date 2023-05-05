locals {
  bookinfo_apps    = split("---", file("${path.module}/istio/samples/bookinfo/platform/kube/bookinfo.yaml"))
  bookinfo_gateway = split("---", file("${path.module}/istio/samples/bookinfo/networking/bookinfo-gateway.yaml"))
}

resource "kubectl_manifest" "bookinfo-app" {
  count      = length(local.bookinfo_apps) - 1
  yaml_body  = local.bookinfo_apps[count.index]
  depends_on = [helm_release.istio_base, helm_release.istio_discovery]
}

resource "kubectl_manifest" "bookinfo-gateway" {
  count      = length(local.bookinfo_gateway)
  yaml_body  = local.bookinfo_gateway[count.index]
  depends_on = [helm_release.istio_base, helm_release.istio_discovery]
}
