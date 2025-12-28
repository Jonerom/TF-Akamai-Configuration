variable "contract" {
  description = "Akamai Contract ID where the CP Code will be created"
  type        = string
}

variable "group" {
  description = "value for group ID where the CP Code will be created"
  type        = string
}

variable "name" {
  description = "Name of the security configuration"
  type        = string
}

variable "description" {
  description = "Description of the security configuration"
  type        = string
  default     = null
}

variable "create_from_config_id" {
  description = "The configuration ID to create this configuration from"
  type        = string
  default     = null
}

variable "create_from_version" {
  description = "The version of the configuration to create this configuration from"
  type        = number
  default     = null
  validation {
    condition     = (var.create_from_config_id != null && var.create_from_version != null) || (var.create_from_config_id == null && var.create_from_version == null)
    error_message = "Both 'create_from_config_id' and 'create_from_version' must be provided in order to create from an existing configuration, or neither to use start from scratch."
  }
}

variable "hostname_list" {
  description = "List of hostnames to associate with this security configuration"
  type        = list(string)
  default     = []
}

variable "security_config" {
  description = "Security configuration settings"
  type = object({
    evasive_path_match_enable     = optional(bool)             # Enable Evasive URL Request Matching
    prefetch_enable_app_layer     = optional(bool)             # Enable Prefetch Requests for Application Layer
    prefetch_all_extensions       = optional(bool)             # Prefetch Requests for All Extensions if prefetch_enable_app_layer is true
    prefetch_extensions           = optional(list(string), []) # List of Extensions for Prefetch Requests if prefetch_all_extensions is false and prefetch_enable_app_layer is true it must be empty []
    prefetch_enable_rate_controls = optional(bool)             # Enable Rate Controls for Prefetch Requests
    request_body_inspection_limit = optional(string)           # Request size inspection limit in KB, possible values: default, 8, 16, 32
    pii_learning_enable           = optional(bool)             # Enable API PII learning
    http_logging = optional(object({                           # Establish HTTP header data logging configuration
      enabled       = optional(string)                         # Enable HTTP header logging
      cookies       = optional(string)                         # Cookie headers to log, possible values: all, none, exclude, only
      custom_type   = optional(string)                         # Custom headers to log, possible values: all, none, exclude, only
      standard_type = optional(string)                         # Standard headers to log, possible values: all, none, exclude, only
    }), {})
    attack_payload_logging = optional(object({ # Establish Attack payload logging configuration
      enabled       = optional(string)         # Enable Attack payload logging
      request_body  = optional(string)         # Log request body, possible values: NONE or ATTACK_PAYLOAD
      response_body = optional(string)         # Log response body, possible values: NONE or ATTACK_PAYLOAD
    }), {})
    siem_settings_enable         = optional(bool)             # Enable SIEM integration
    siem_enable_for_all_policies = optional(bool)             # Enable SIEM integration for all security policies
    siem_security_policy_ids     = optional(list(string), []) # List of security policy IDs to enable SIEM integration for, if siem_enable_for_all_policies is false it must be empty []
    siem_id                      = optional(number)           # SIEM integration ID to use
    siem_include_ja4_fingerprint = optional(bool)             # Include JA4 fingerprint in SIEM logs
    siem_exception_list = optional(list(object({              # Establish SIEM Exception List configuration
      api_request_constraints = optional(set(string))         # Establish API Request Constraints for SIEM Exception List
      apr_protection          = optional(set(string))         # Establish APR Protection for SIEM Exception List
      bot_management          = optional(set(string))         # Establish Bot Management for SIEM Exception List
      client_rep              = optional(set(string))         # Establish Client Reputation for SIEM Exception List
      custom_rules            = optional(set(string))         # Establish Custom Rules for SIEM Exception List
      ip_geo                  = optional(set(string))         # Establish IP Geo for SIEM Exception List
      malware_protection      = optional(set(string))         # Establish Malware Protection for SIEM Exception List
      rate                    = optional(set(string))         # Establish Rate for SIEM Exception List
      slow_post               = optional(set(string))         # Establish Slow Post for SIEM Exception List
      url_protection          = optional(set(string))         # Establish URL Protection for SIEM Exception List
      waf                     = optional(set(string))         # Establish WAF for SIEM Exception List
    })), [])
    pragma_header = optional(object({                     # Establish Strip Pragma debug headers from responses configuration
      action                 = optional(string)           # Action to apply to Pragma debug headers, possible values: REMOVE
      conditional_operator   = optional(string)           # Condition operator for excluding certain requests from header removal, possible values: AND (ALL), OR (ANY)
      exclude_condition_list = optional(list(string), []) # List of conditions to exclude from header removal, find details at https://techdocs.akamai.com/application-security/reference/put-advanced-settings-pragma-header
    }), {})
  })
  default = {
    evasive_path_match_enable     = true
    prefetch_enable_app_layer     = true
    prefetch_all_extensions       = false
    prefetch_extensions           = ["cgi", "jsp", "aspx", "EMPTY_STRING", "php", "py", "asp"]
    prefetch_enable_rate_controls = false
    request_body_inspection_limit = "32"
    pii_learning_enable           = false
    http_logging = {
      enabled       = "true"
      cookies       = "all"
      custom_type   = "all"
      standard_type = "all"
    }
    attack_payload_logging = {
      enabled       = "true"
      request_body  = "ATTACK_PAYLOAD"
      response_body = "ATTACK_PAYLOAD"
    }
    siem_settings_enable         = true
    siem_enable_for_all_policies = true

    siem_id                      = 1
    siem_include_ja4_fingerprint = false
    pragma_header = {
      action               = "REMOVE"
      conditional_operator = ""
    }
  }
  nullable = false
}
