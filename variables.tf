variable "tenancy_ocid" {
  description = "OCID de la tenencia OCI."
  type        = string
}

variable "user_ocid" {
  description = "OCID del usuario OCI."
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint de la clave API."
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Ruta al archivo de clave privada API."
  type        = string
}

variable "region" {
  description = "Región de OCI."
  type        = string
}

variable "compartment_ocid" {
  description = "OCID del compartimento donde se crearán los recursos."
  type        = string
}

variable "ssh_public_key" {
  description = "Clave pública SSH para la instancia."
  type        = string
  sensitive   = true # Marca como sensible para no mostrar en logs
}
