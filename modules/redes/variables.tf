variable "compartment_ocid" {
  description = "OCID del compartimento."
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR block para la VCN."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block para la subred."
  type        = string
  default     = "10.0.1.0/24"
}
