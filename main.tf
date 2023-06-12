terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.69.0"
    }
  }
}

provider "google" {
  credentials = file("eitan-tetrate-9511fdb9bfa2.json")

  project = "eitan-tetrate"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_instance" "tsb_vm" {
  name         = "tsb-vm"
  machine_type = "e2-standard-8"

  tags         = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size = 30
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    user-data = templatefile("${path.module}/vm-userdata.tftpl", {
      tsb_image_sync_username = var.tsb_image_sync_username
      tsb_image_sync_apikey   = var.tsb_image_sync_apikey
    })
  }
}
