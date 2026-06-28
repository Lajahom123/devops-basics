resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.15.1"

  values = [
    file("${path.root}/../../helm/infrastructure/ingress-nginx/values.yaml"),
    file("${path.root}/../../helm/infrastructure/ingress-nginx/values-dev.yaml"),
  ]

  depends_on = [
    module.aks,
  ]
}
