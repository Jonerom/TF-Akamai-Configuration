variable "config_id" {
  description = "The ID of the security configuration to activate."
  type        = string
}
variable "latest_version" {
  description = "The latest version number of the security configuration."
  type        = number
}
variable "activation_note" {
  description = "A note to include with the activation."
  type        = string
  default     = null
}
variable "support_team_emails" {
  description = "List of email addresses to notify about the activation."
  type        = list(string)
}
