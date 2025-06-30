output "vcn_id" {
  description = "OCID de la VCN creada."
  value       = oci_core_virtual_network.vcn.id
}

output "subnet_id" {
  description = "OCID de la subred creada."
  value       = oci_core_subnet.subnet.id
}

output "availability_domain_name" {
  description = "Nombre del primer Availability Domain disponible."
  value       = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

output "security_list_id" {
  description = "OCID de la Security List creada."
  value       = oci_core_security_list.sec_list.id
}
