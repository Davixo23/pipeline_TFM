resource "oci_core_instance" "ubuntu_vm" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  shape               = "VM.Standard.E2.1.Micro"
  display_name        = "jenkins_ubuntu_vm"

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    hostname_label   = "jenkinsvm"
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaakegir47dteltlxz2jvo4qkthchtb6s7qc66cife74y6vok3gfi6q" # Ubuntu 22.04 x86_64 São Paulo
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = var.user_data_script
  }
}

output "instance_public_ip" {
  description = "IP pública de la instancia."
  value       = oci_core_instance.ubuntu_vm.public_ip
}
