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

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  chart = "${path.root}/../../helm/infrastructure/cert-manager"

  values = [
    file("${path.root}/../../helm/infrastructure/cert-manager/values.yaml"),
    file("${path.root}/../../helm/infrastructure/cert-manager/values-dev.yaml"),
  ]

  depends_on = [
    module.aks,
    helm_release.ingress_nginx,
  ]
}

resource "helm_release" "keyvault_csi_driver" {
  name      = "csi-secrets-store-provider-azure"
  namespace = "kube-system"

  repository = "https://azure.github.io/secrets-store-csi-driver-provider-azure/charts"
  chart      = "csi-secrets-store-provider-azure"
  version    = "1.6.1"

  set {
    name  = "secrets-store-csi-driver.syncSecret.enabled"
    value = "false"
  }
}