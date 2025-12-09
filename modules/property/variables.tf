variable "contract" {
  description = "Akamai Contract ID where the Property will be created"
  type        = string
}

variable "group" {
  description = "value for group ID where the Property will be created"
  type        = string
}

variable "product_id" {
  description = "Akamai Product ID associated with the Property"
  type        = string
}

variable "name" {
  description = "Name of the Property to be created. Only letters, numbers, dots (.), underscores (_) and hyphens (-) are allowed."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9\\._-]+$", var.name))
    error_message = "The string must not contain special characters nor commas (,), spaces, quotes ('\"), pound signs (#), carets (^), or percent signs (%). Only letters, numbers, underscores (_), dots (.), and hyphens (-) are allowed."
  }
}

variable "support_team_emails" {
  description = "Email address(es) of the support team(s) for notifications related to the Property activations"
  type        = list(string)
}

variable "rule_format" {
  description = "Rule format for the Property. Possible values: 'latest' or see specific values: https://techdocs.akamai.com/terraform/docs/pm-ds-rule-formats"
  type        = string
  default     = null
}

variable "cp_code_id" {
  description = "ID of the CP Code to be associated with the Property"
  type        = string
}

variable "site_shield_name" {
  description = "Name of the Site Shield to be associated with the Property"
  type        = string
  default     = null
}

variable "edge_hostname" {
  description = "Edge Hostname to be associated with the Property"
  type        = string
  default     = null
}

variable "host_configuration" {
  description = "Map of zones with lists of records for Subject Alternative Names (SANs) for the certificate"
  type = map(object({
    zone_name = string                          # DNS Zone name. Only letters, numbers, underscores (_), dots (.), and hyphens (-) are allowed. eg. example.com
    records = list(object({                     # List of DNS records to be created in the zone
      name                   = string           # DNS record name (e.g., www), keep empty "" for root domain as akamai does not support @
      type                   = optional(string) # DNS record type (e.g., A, CNAME, MX, AKAMAICDN, AKAMAITLC, TXT), optional for WAF properties
      targets                = list(string)     # DNS record target values (IPs, domain names, etc.) varies by record type
      ttl                    = optional(number) # DNS record TTL in seconds (If not set, default value will be used)
      priority               = optional(number) # DNS record priority if applicable to all targets, else don't set
      type_value             = optional(number) # DNS record type value
      cert_provisioning_type = optional(string) # Certificate provisioning type for the hostname, possible values: CPS_MANAGED, DEFAULT or CCM
      ccm_certificates = optional(object({      # CCM certificate details for the hostname if cert_provisioning_type is CCM
        id   = string                           # The certificate ID (e.g., "12345")
        type = string                           # The certificate type, possible values: ecdsa" or "rsa"
      }))
    }))
  }))
}

variable "version_notes" {
  description = "Version note for the Property"
  type        = string
  default     = null
}

variable "activation_note" {
  description = "Activation note for the Property"
  type        = string
  default     = null
}

variable "auto_acknowledge_rule_warnings_staging" {
  description = "Flag to auto acknowledge rule warnings during staging activation"
  type        = bool
  default     = null
}

variable "auto_acknowledge_rule_warnings_production" {
  description = "Flag to auto acknowledge rule warnings during production activation"
  type        = bool
  default     = null
}

variable "timeout_staging_activation" {
  description = "Timeout for Property's staging activation operation default 20m"
  type        = string
  default     = null
}

variable "timeout_production_activation" {
  description = "Timeout for Property's production activation operation overriding default 20m"
  type        = string
  default     = null
}
