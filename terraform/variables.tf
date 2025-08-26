variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "region" {
  description = "Región por defecto"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona por defecto"
  type        = string
  default     = "us-central1-a"
}

variable "name_prefix" {
  description = "Prefijo para nombrar recursos"
  type        = string
  default     = "demo"
}

variable "machine_type" {
  description = "Tipo de máquina (e2-micro, e2-medium, n2-standard-2, etc.)"
  type        = string
  default     = "e2-micro"
}

variable "boot_image" {
  description = "Family/imagen para el disco de arranque (recomendado usar family LTS)"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "boot_disk_gb" {
  description = "Tamaño del disco de arranque en GB"
  type        = number
  default     = 20
}

variable "env" {
  description = "Etiqueta de entorno (dev, intg, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Etiqueta de propietario"
  type        = string
  default     = "antonio"
}

