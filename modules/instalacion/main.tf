output "user_data_script_base64" {
  description = "Script de user_data codificado en Base64."
  value       = base64encode(file("${path.module}/scripts/setup.sh"))
}
