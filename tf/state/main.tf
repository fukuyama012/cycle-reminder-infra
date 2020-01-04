variable "project" {}

locals {
  bucket_name = "cr-terraform-state"
}

provider "google" {
  project = var.project
  region  = module.common.region
  zone    = module.common.zone
}

terraform {
  backend "gcs" {
    bucket  = "cr-terraform-state"
    prefix = "state"
  }
}

module "common" {
  source = "../common"
}

resource "google_storage_bucket" "terraform-state-store" {
  name     = local.bucket_name
  location = module.common.region
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5
    }
  }
}
