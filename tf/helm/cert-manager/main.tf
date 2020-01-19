provider "helm" {
  service_account = module.common.tiller_account_name
}

terraform {
  backend "gcs" {
    bucket  = "cr-terraform-state"
    prefix = "helm/cert-manager"
  }
}

module "common" {
  source = "../../common"
}

data "helm_repository" "cert_manager" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "helm_release" "cert_manager" {
  name      = "cert-manager"
  namespace = "cert-manager"
  repository = data.helm_repository.cert_manager.metadata[0].name
  chart = "cert-manager"
  version = "v0.10.1"
}
