#!/bin/bash
set -e

export TF_VAR_private_key_path="$1"
ACTION="$2"

terraform init
terraform plan -out=tfplan

if [ "$ACTION" = "apply" ]; then
  terraform apply -auto-approve tfplan

  # Guardar la IP pública en un archivo
  terraform output -raw instance_public_ip > instance_public_ip.txt

elif [ "$ACTION" = "destroy" ]; then
  terraform destroy -auto-approve
else
  echo "Acción no soportada: $ACTION"
  exit 1
fi
