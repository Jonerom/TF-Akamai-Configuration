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
variable "security_policy_id" {
  type        = number
  description = "The Security Policy ID"
}
variable "enable_bot_management" { type = bool }
variable "third_party_proxy_service_in_use" { type = bool }
variable "remove_bot_management_cookies" { type = bool }
variable "enable_active_detections" { type = bool }
# Optional bool variables default to false
variable "add_akamai_bot_header" {
  type    = bool
  default = false
}
variable "enable_browser_validation" {
  type    = bool
  default = false
}
variable "include_transactional_endpoint_requests" {
  type    = bool
  default = false
}
variable "include_transactional_endpoint_status" {
  type    = bool
  default = false
}

locals {
  payload = {
    enableBotManagement                  = var.enable_bot_management
    addAkamaiBotHeader                   = var.add_akamai_bot_header
    thirdPartyProxyServiceInUse          = var.third_party_proxy_service_in_use
    removeBotManagementCookies           = var.remove_bot_management_cookies
    enableActiveDetections               = var.enable_active_detections
    enableBrowserValidation              = var.enable_browser_validation
    includeTransactionalEndpointRequests = var.include_transactional_endpoint_requests
    includeTransactionalEndpointStatus   = var.include_transactional_endpoint_status
  }
}

resource "terraform_data" "update_bot_settings" {
  input = {
    payload_hash = jsonencode(local.payload)
    policy_id    = var.security_policy_id
    config_id    = var.config_id
  }
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/bot-management-settings.exe \
        -edgerc "${var.edgerc_path}" \
        -section "${var.edgerc_section}" \
        -config-id ${var.config_id} \
        -security-policy-id "${var.security_policy_id}" \
        -payload '${jsonencode(local.payload)}'
    EOT
  }
}
