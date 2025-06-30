output "instance_public_ip" {
  description = "IP pública de la instancia creada."
  value       = module.instancia.instance_public_ip
}

output "vcn_id" {
  description = "OCID de la VCN creada."
  value       = module.redes.vcn_id
}

output "subnet_id" {
  description = "OCID de la subred creada."
  value       = module.redes.subnet_id
}
