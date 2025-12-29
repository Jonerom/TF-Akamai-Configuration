variable "edge_hostname" {
  description = "The full Edge Hostname to wait for (e.g., foo.example.edgesuite.net)"
  type        = string
}
variable "edgerc_path" {
  description = "Path to .edgerc"
  default     = "~/.edgerc"
}
variable "edgerc_section" {
  description = "Section in .edgerc"
  default     = "default"
}
variable "timeout_minutes" {
  description = "Maximum time to wait (in minutes)"
  type        = number
  default     = 30
}
variable "polling_interval" {
  description = "Time between checks (in seconds)"
  type        = number
  default     = 20
}

resource "terraform_data" "wait_for_edge_hostname" {
  input = {
    hostname = var.edge_hostname
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/ehm_waiter.exe \
        -edgerc "${var.edgerc_path}" \
        -section "${var.edgerc_section}" \
        -hostname "${var.edge_hostname}" \
        -timeout ${var.timeout_minutes} \
        -interval ${var.polling_interval}
    EOT
  }
}
