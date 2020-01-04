variable "project" {}

provider "google" {
  project = var.project
  region  = module.common.region
  zone    = module.common.zone
}

terraform {
  backend "gcs" {
    bucket  = "cr-terraform-state"
    prefix = "gke"
  }
}

module "common" {
  source = "../common"
}

locals {
  node_version = "1.14.9-gke.2"
  machine_type = "e2-micro"
  disk_size_gb = 10
}

resource "google_container_cluster" "primary" {
  name     = "cr-cluster"
  location = module.common.zone

  remove_default_node_pool = true
  initial_node_count = 1

  cluster_autoscaling {
    enabled = false
  }

  network = module.common.network

  min_master_version = local.node_version
  node_version       = local.node_version
  
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "node" {
  name       = "cr-node"
  location   = module.common.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1
  version    = local.node_version

  management {
    auto_repair = true
  }

  node_config {
    machine_type = local.machine_type
    disk_size_gb = local.disk_size_gb

    metadata = {
      disable-legacy-endpoints = true
      auto_upgrade = false
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
  }
}

resource "google_container_node_pool" "node_preemptible" {
  name       = "cr-node-preemptible"
  location   = module.common.zone
  cluster    = google_container_cluster.primary.name
  node_count = 2
  version    = local.node_version

  management {
    auto_repair = true
    auto_upgrade = false
  }

  node_config {
    preemptible  = true
    machine_type = local.machine_type
    disk_size_gb = local.disk_size_gb

    metadata = {
      disable-legacy-endpoints = true
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
  }
}