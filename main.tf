terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.30.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Llama al módulo de redes
module "redes" {
  source           = "./modules/redes"
  compartment_ocid = var.compartment_ocid
  vcn_cidr         = "10.0.0.0/16"
  subnet_cidr      = "10.0.1.0/24"
  providers = {
    oci = oci
  }
}

# Llama al módulo de instalación
module "instalacion" {
  source = "./modules/instalacion"
  providers = {
    oci = oci
  }
}

# Llama al módulo de instancia
module "instancia" {
  source              = "./modules/instancia"
  compartment_ocid    = var.compartment_ocid
  availability_domain = module.redes.availability_domain_name # Usar el output del módulo redes
  subnet_id           = module.redes.subnet_id                # Usar el output del módulo redes
  ssh_public_key      = var.ssh_public_key
  user_data_script    = module.instalacion.user_data_script_base64 # Usar el output del módulo instalacion
  providers = {
    oci = oci
  }
}
