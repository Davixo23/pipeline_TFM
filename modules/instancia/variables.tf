variable "compartment_ocid" {
  description = "OCID del compartimento."
  type        = string
}

variable "availability_domain" {
  description = "Nombre del Availability Domain."
  type        = string
}

variable "subnet_id" {
  description = "OCID de la subred donde se desplegará la instancia."
  type        = string
}

variable "ssh_public_key" {
  description = "Clave pública SSH para la instancia."
  type        = string
}

variable "user_data_script" {
  description = "Script de user data codificado en Base64."
  type        = string
}
