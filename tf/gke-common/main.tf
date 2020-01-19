variable "project" {}

provider "google" {
  project = var.project
  region  = module.common.region
  zone    = module.common.zone
}

terraform {
  backend "gcs" {
    bucket  = "cr-terraform-state"
    prefix = "gke-common"
  }
}

module "common" {
  source = "../common"
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name = module.common.tiller_account_name
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = module.common.tiller_account_name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = module.common.tiller_account_name
    namespace = "kube-system"
  }
  depends_on = [kubernetes_service_account.tiller]
}
