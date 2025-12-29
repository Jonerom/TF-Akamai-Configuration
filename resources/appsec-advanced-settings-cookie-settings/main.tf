variable "edgerc_path" {
  type        = string
  description = "Path to the .edgerc file"
  default     = "~/.edgerc"
}
variable "edgerc_section" {
  type        = string
  description = "Section of the .edgerc file to use"
  default     = "default"
}
variable "config_id" {
  type        = number
  description = "The Application Security Configuration ID"
}
variable "use_all_secure_traffic" {
  type        = bool
  description = "If true, sets Secure flag on cookies and SameSite=None."
}

resource "terraform_data" "update_cookie_settings" {
  input = {
    config_id = var.config_id
    secure    = var.use_all_secure_traffic
  }
  provisioner "local-exec" {
    # We pass the boolean flag. 
    # Note: For Go boolean flags, we use -flag=value (e.g., -use-all-secure=true)
    command = <<EOT
      ${path.module}/cookie-settings.exe \
        -edgerc "${var.edgerc_path}" \
        -section "${var.edgerc_section}" \
        -config-id ${var.config_id} \
        -use-all-secure=${var.use_all_secure_traffic}
    EOT
  }
}
