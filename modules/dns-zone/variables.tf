variable "contract" {
  description = "value for contract ID where the zone will be created"
  type        = string
}

variable "group" {
  description = "value for group ID where the zone will be created"
  type        = string
}

variable "zone" {
  description = "Zone name to be created, e.g., example.com"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9\\._-]+$", var.zone))
    error_message = "The string must not contain special characters nor commas (,), spaces, quotes ('\"), pound signs (#), carets (^), or percent signs (%). Only letters, numbers, underscores (_), dots (.), and hyphens (-) are allowed."
  }
}

variable "type" {
  description = "value for zone type, possible values: primary, secondary or alias"
  type        = string
  default     = "primary"
  nullable    = false
}

variable "comment" {
  description = "Optional comment for the DNS zone"
  type        = string
  default     = "Managed by Terraform"
}

variable "end_customer_id" {
  description = "End Customer free-form identifier for the DNS zone"
  type        = string
  default     = null
}

variable "masters" {
  description = "List of master DNS servers for secondary zones"
  type        = list(string)
  default     = []
}

variable "sns" {
  description = "Enable Sign and Serve (SNS) for the DNS zone"
  type        = bool
  default     = false
}

variable "sns_algorithm" {
  description = "Algorithm used for Sign and Serve (SNS)"
  type        = string
  default     = null
}


variable "tsig_key" {
  description = "TSIG key for secure zone transfers (used for secondary zones)"
  type = object({
    name      = string
    algorithm = string
    secret    = string
  })
  default   = null
  sensitive = true
}

variable "outbound_zone_transfer_tsig_key" {
  description = "TSIG key for outbound zone transfers"
  type = object({
    name      = string
    algorithm = string
    secret    = string
  })
  default   = null
  sensitive = true
}

variable "outbound_zone_transfer" {
  description = "Configuration for outbound zone transfers"
  type = object({
    enabled        = bool
    acl            = list(string)
    notify_targets = list(string)
  })
  default = null
}

variable "target" {
  description = "Target zone for alias zones"
  type        = string
  default     = null
}
