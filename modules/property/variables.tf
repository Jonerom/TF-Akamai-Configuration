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

variable "edge_hostname_type" {
  description = "Edge Hostname type as per ceritificate type, possible values: enhanced, standard, shared or non-tls"
  type        = string
  default     = "null"
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

## Rule Configuration Variables
# Use either of the following variables to define the Property rules:
# custom_json_rules: for a provided complete set of rules including the default base rule
# default_json_rule_values + (basic_json_rule_values or additional_json_rules) : to generate the base default rules and merge additional partial
variable "custom_json_rules" {
  description = "JSON string representing the Complete set of rules for the Property including the default base rule"
  type        = string
  default     = null
}

variable "default_json_rule_values" {
  description = "Set of values to customize the default JSON rules for the Property generated by the module"
  # Further origin_type specific value information can be found at https://techdocs.akamai.com/property-mgr/reference/ga-origin
  type = object({
    comments    = optional(string, "The behaviors in the default rule apply to all requests for the property hostnames unless another rule overrides these settings.")
    origin_type = string # Origin type for the default origin behavior, possible values: CUSTOMER, NET_STORAGE or AKAMAI_OBJECT_STORAGE
    # CUSTOMER origin type values
    forward_host_header           = optional(string, "REQUEST_HOST_HEADER") # Sets the Host header sent to the origin server, possible values: REQUEST_HOST_HEADER, ORIGIN_HOSTNAME or CUSTOM
    custom_forward_host_header    = optional(string, null)                  # Host header value when forward_host_header is set to CUSTOM
    cache_key_hostname            = optional(string, "REQUEST_HOST_HEADER") # Hostname used in the cache key, possible values: REQUEST_HOST_HEADER or ORIGIN_HOSTNAME
    ip_version                    = optional(string, "DUAL_STACK")          # IP version used to connect to the origin, possible values: IPV4, IPV6 or DUAL_STACK
    compress                      = optional(bool, true)                    # Flag to enable gzip compression between Akamai and the origin
    enable_true_client_ip         = optional(bool, true)                    # Flag to enable True-Client-IP header to be sent to the origin
    true_client_ip_header         = optional(string, "True-Client-IP")      # Name of the True-Client-IP header sent to the origin when enable_true_client_ip is true
    true_client_ip_client_setting = optional(bool, false)                   # Flag to enable client setting for True-Client-IP header when enable_true_client_ip is true
    http_port                     = optional(number, 80)                    # Origin HTTP port
    https_port                    = optional(number, 443)                   # Origin HTTPS port
    min_tls_version               = optional(string, "TLSV1_2")             # Minimum TLS version for HTTPS connections to the origin, possible values: TLSV1_1, TLSV1_2, TLSV1_3 or DYNAMIC
    origin_sni                    = optional(bool, true)                    # Flag to enable SNI for HTTPS connections to the origin
    verification_mode             = optional(string, "PLATFORM_SETTINGS")   # Origin certificate verification mode, possible values: PLATFORM_SETTINGS, THIRD_PARTY or CUSTOM
    custom_valid_cn_values        = optional(string, null)                  # Custom common name values for origin certificate verification when verification_mode is CUSTOM
    origin_certs_to_honor         = optional(string, null)                  # Origin certificates to honor when verification_mode is CUSTOM, possible values: COMBO (all), STANDARD_​CERTIFICATE_​AUTHORITIES, CUSTOM_​CERTIFICATE_​AUTHORITIES	 or CUSTOM_​CERTIFICATES
    # NET_STORAGE origin type values
    net_storage = optional(object({
      account_id   = string                 # NetStorage account ID
      origin_host  = string                 # NetStorage origin hostname
      use_sps      = optional(bool, false)  # Flag to use Secure Path Service (SPS) for NetStorage origin authentication
      sps_key_name = optional(string, null) # SPS key name for NetStorage origin authentication when use_sps is true
    }))
    # AKAMAI_OBJECT_STORAGE origin type values
    akamai_object_storage = optional(object({
      container_name = string # Akamai Object Storage container name
      origin_host    = string # Akamai Object Storage origin hostname
    }))
    # Caching behavior values
    caching_behavior      = optional(string, "")   # Caching behavior option in the mandatory rules, possible values: "NO_STORE", "BYPASS_CACHE", "MAX_AGE", "EXPIRES", "CACHE_CONTROL" or "CACHE_CONTROL_AND_EXPIRES"
    must_revalidate       = optional(bool, null)   # Flag to set the Must-Revalidate directive in the caching behavior of the mandatory rules, valid only for "MAX_AGE", "EXPIRES", "CACHE_CONTROL" and "CACHE_CONTROL_AND_EXPIRES"
    ttl                   = optional(string, null) # TTL value in for the caching behavior of the mandatory rules (eg: 30s, 1m, 2h), valid only for "MAX_AGE","EXPIRES", "CACHE_CONTROL" and "CACHE_CONTROL_AND_EXPIRES"
    enhanced_rfc_support  = optional(bool, null)   # Flag to enable enhanced RFC compliance in the caching behavior of the mandatory rules, valid only for "CACHE_CONTROL" and "CACHE_CONTROL_AND_EXPIRES"
    honor_private         = optional(bool, null)   # Flag to honor private caching directives in the caching behavior of the mandatory rules, valid only for "CACHE_CONTROL" and "CACHE_CONTROL_AND_EXPIRES"
    honor_must_revalidate = optional(bool, null)   # Flag to honor must-revalidate directives in the caching behavior of the mandatory rules, valid only for "CACHE_CONTROL" and "CACHE_CONTROL_AND_EXPIRES"
  })
  default = {}
  validation {
    condition     = (length(try(var.custom_json_rules, "")) > 0) || try(var.default_json_rule_values.origin_type, false)
    error_message = "Either 'custom_json_rules' or 'default_json_rule_values' must be provided."
  }
}

variable "basic_json_rules" {
  description = "Flag to setup the base default JSON rules for the Property generated by the module"
  type        = bool
  default     = false
}

variable "additional_json_rules" {
  description = "list of JSON strings representing a customized subsets of rules for the Property to be merged into the base rules"
  type        = list(string)
  default     = null
  validation {
    condition     = (length(try(var.additional_json_rules, "")) > 0) || var.basic_json_rules
    error_message = "Either 'additional_json_rules' or 'basic_json_rules' must be provided."
  }
}
