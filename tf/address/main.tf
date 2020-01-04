variable "project" {}

provider "google" {
  project = var.project
  region  = module.common.region
  zone    = module.common.zone
}

terraform {
  backend "gcs" {
    bucket  = "cr-terraform-state"
    prefix = "address"
  }
}

module "common" {
  source = "../common"
}

resource "google_compute_address" "cluster-ip" {
  name = "cr-cluster-ip"
  region = module.common.region
}