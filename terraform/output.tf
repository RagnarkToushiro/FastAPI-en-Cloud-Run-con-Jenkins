output "instance_name" {
  description = "Nombre de la instancia"
  value       = module.vm.instance_name
}

output "instance_self_link" {
  description = "Self link de la instancia"
  value       = module.vm.instance_self_link
}

output "external_ip" {
  description = "IP pública (si se asignó access_config)"
  value       = try(module.vm.external_ip, null)
}

output "ssh_example" {
  description = "Comando SSH sugerido (OS Login habilitado)"
  value       = "gcloud compute ssh ${module.vm.instance_name} --zone ${var.zone}"
}

