terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.69.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_filename)

  project = "eitan-tetrate"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
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
      pubkey                  = tls_private_key.generated.public_key_openssh
    })
  }
}

resource "local_file" "tsbadmin_pem" {
  filename        = "gcp-ubuntu.pem"
  file_permission = "0600"
  content         = tls_private_key.generated.private_key_pem
  depends_on      = [tls_private_key.generated]
}

resource "local_file" "ssh_jumpbox" {
  filename        = "ssh-to-gcp-vm.sh"
  file_permission = "0755"
  content         = "ssh -i gcp-ubuntu.pem ubuntu@${google_compute_instance.tsb_vm.network_interface[0].access_config[0].nat_ip}"
  depends_on      = [local_file.tsbadmin_pem]
}
