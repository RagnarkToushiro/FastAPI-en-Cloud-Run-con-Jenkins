terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Habilitar API de Compute (por si el proyecto es nuevo)
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

# SA dedicada para la VM (buenas prácticas)
resource "google_service_account" "vm_sa" {
  account_id   = "${var.name_prefix}-vm-sa"
  display_name = "SA for VM"
}

# Subred "default" en la región indicada (auto mode VPC)
# Self link explícito para evitar ambigüedades
locals {
  default_subnet_self_link = "projects/${var.project_id}/regions/${var.region}/subnetworks/default"
}

# ==========================
#   VM con módulo oficial
# ==========================
module "vm" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 10.0"

  project_id   = var.project_id
  zone         = var.zone
  name         = "${var.name_prefix}-vm"
  machine_type = var.machine_type
  tags         = ["ssh"] # útil si decides filtrar firewall por tags más adelante

  # Disco de arranque
  source_image = var.boot_image       # family estable
  disk_size_gb = var.boot_disk_gb
  disk_type    = "pd-balanced"

  # Red por defecto + IP pública (quítala si no la necesitas)
  network_interfaces = [{
    subnetwork    = local.default_subnet_self_link
    access_config = [{}]    # <- quita este bloque para NO exponer IP pública
  }]

  # OS Login y script de arranque de ejemplo
  metadata = {
    enable-oslogin = "TRUE"
    startup-script = <<-EOT
      #!/usr/bin/env bash
      set -euxo pipefail
      apt-get update -y
      apt-get install -y nginx
      systemctl enable --now nginx
    EOT
  }

  # SA y scopes mínimos razonables (mejor que cloud-platform)
  service_account = {
    email  = google_service_account.vm_sa.email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }

  labels = {
    env   = var.env
    owner = var.owner
  }

  depends_on = [google_project_service.compute]
}

