provider "helm" {
  service_account = module.common.tiller_account_name
}

terraform {
  backend "gcs" {
    bucket  = "cr-terraform-state"
    prefix = "helm/nginx-ingress"
  }
}

module "common" {
  source = "../../common"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "nginx_ingress" {
  name      = "nginx-ingress"
  repository = data.helm_repository.stable.metadata[0].name
  chart     = "stable/nginx-ingress"
  namespace = "nginx-ingress"

  set {
    name = "rbac.create"
    value = true
  }

  set {
    name = "controller.publishService.enabled"
    value = true
  }
}
