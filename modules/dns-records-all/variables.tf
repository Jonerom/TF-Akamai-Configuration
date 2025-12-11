variable "zone" {
  description = "Zone name for the DNS record, e.g., example.com"
  type        = string
}

variable "record" {
  description = "DNS record name, e.g., www"
  type        = string
}

variable "type" {
  description = "Type of DNS record, e.g., A, CNAME, MX, AKAMAICDN, AKAMAITLC, TXT"
  type        = string
}

variable "ttl" {
  description = "value for DNS record TTL (time to live) in seconds, default is 30 minutes445"
  type        = number
  default     = 1800
}

variable "target_list" {
  description = "List of target values for the DNS record, e.g., comma separated list of IP addresses, domain names, or other values depending on the record type"
  type        = list(string)
  default     = null
}

variable "algorithm" {
  description = "Public key algorithm for DNS records"
  type        = number
  default     = null
}

variable "certificate" {
  description = "Base64 encoded value of certificate data for DNS records"
  type        = string
  default     = null
}

variable "digest" {
  description = "Base16 encoded DS record digest value for specific DNS records"
  type        = string
  default     = null
}

variable "digest_type" {
  description = "Digest type for specific DNS records"
  type        = number
  default     = null
}

variable "email_address" {
  description = "Email address for specific DNS records"
  type        = string
  default     = null
}

variable "expiration" {
  description = "Expiration time for specific DNS records"
  type        = number
  default     = null
}

variable "expiry" {
  description = "Expiry number for specific DNS records"
  type        = number
  default     = null
  validation {
    condition     = var.expiry >= 0 && var.expiry <= 214748364
    error_message = "The expiry must be a value between 0 and 214748364, inclusive."
  }
}

variable "fingerprint" {
  description = "Base16 encoded Fingerprint data for specific DNS records"
  type        = string
  default     = null
}

variable "fingerprint_type" {
  description = "Fingerprint type for specific DNS records"
  type        = number
  default     = null
}

variable "flags" {
  description = "Flags for specific DNS records"
  type        = number
  default     = null
}

variable "flagsnaptr" {
  description = "A character string containing single alphanumeric flags for specific DNS records"
  type        = string
  default     = null
}

variable "hardware" {
  description = "Hardware address for specific DNS records"
  type        = string
  default     = null
}

variable "inception" {
  description = "Inception time for specific DNS records"
  type        = number
  default     = null
}

variable "iterations" {
  description = "Number of iterations for specific DNS records"
  type        = number
  default     = null
}

variable "key" {
  description = "Public key data for specific DNS records"
  type        = string
  default     = null
}

variable "keytag" {
  description = "Key tag for specific DNS records"
  type        = number
  default     = null
}

variable "labels" {
  description = "Number of labels for specific DNS records"
  type        = number
  default     = null
}

variable "mailbox" {
  description = "Mailbox for specific DNS records"
  type        = string
  default     = null
}

variable "match_type" {
  description = "Match type for specific DNS records"
  type        = number
  default     = null
}

variable "name_server" {
  description = "Name server for specific DNS records"
  type        = string
  default     = null
}

variable "next_hashed_owner_name" {
  description = " Base32 encoded in binary format next hashed owner name for specific DNS records"
  type        = string
  default     = null
}

variable "nxdomain_ttl" {
  description = "Nxdomain_ttl number for specific DNS records"
  type        = number
  default     = null
  validation {
    condition     = var.nxdomain_ttl >= 0 && var.nxdomain_ttl <= 214748364
    error_message = "The nxdomain_ttl must be a value between 0 and 214748364, inclusive."
  }
}

variable "order" {
  description = "16-bit unsigned integer specifying the order for specific DNS records"
  type        = number
  default     = null
}

variable "original_ttl" {
  description = "Original TTL for specific DNS records"
  type        = number
  default     = null
}

variable "port" {
  description = "Port number for specific DNS records"
  type        = number
  default     = null
  validation {
    condition     = var.port >= 0 && var.port <= 65535
    error_message = "The port must be a value between 0 and 65535, inclusive."
  }
}

variable "preference" {
  description = "16-bit unsigned integer specifying the preference for specific DNS records"
  type        = number
  default     = null
}

variable "priority" {
  description = "16-bit integer that specifies priority i (for MX, SRV, etc.), if applicable to all targets for specific DNS records"
  type        = number
  default     = null
}

variable "priority_increment" {
  description = "value for increment when multiple targets are provided with no embedded priority for specific DNS records"
  type        = number
  default     = null
}

variable "protocol" {
  description = "Protocol for specific DNS records"
  type        = number
  default     = null
}

variable "refresh" {
  description = "Refresh number for specific DNS records"
  type        = number
  default     = null
  validation {
    condition     = var.refresh >= 0 && var.refresh <= 214748364
    error_message = "The refresh must be a value between 0 and 214748364, inclusive."
  }
}

variable "regexp" {
  description = "Regex pattern for specific DNS records"
  type        = string
  default     = null
}

variable "replacement" {
  description = "Replacement field for specific DNS records"
  type        = string
  default     = null
}

variable "retry" {
  description = "Retry number for specific DNS records"
  type        = number
  default     = null
  validation {
    condition     = var.retry >= 0 && var.retry <= 214748364
    error_message = "The retry must be a value between 0 and 214748364, inclusive."
  }
}

variable "salt" {
  description = "Base16 encoded salt value value for specific DNS records"
  type        = string
  default     = null
}

variable "selector" {
  description = "Selector for specific DNS records"
  type        = number
  default     = null
}

variable "serial" {
  description = "Serial number for specific DNS records"
  type        = number
  default     = null
  validation {
    condition     = var.serial >= 0 && var.serial <= 214748364
    error_message = "The serial must be a value between 0 and 214748364, inclusive."
  }
}

variable "service" {
  description = "Service field for specific DNS records"
  type        = string
  default     = null
}

variable "signature" {
  description = "Signature data for specific DNS records"
  type        = string
  default     = null
}

variable "signer" {
  description = "Signer name for specific DNS records"
  type        = string
  default     = null
}

variable "software" {
  description = "Software address for specific DNS records"
  type        = string
  default     = null
}

variable "subtype" {
  description = "Subtype for certain DNS record types, e.g., AFSDB, if applicable to all targets; value must be between 0-65535"
  type        = number
  default     = null
  validation {
    condition     = var.subtype >= 0 && var.subtype <= 65535
    error_message = "The subtype must be a value between 0 and 65535, inclusive."
  }
}

variable "svc_params" {
  description = "Space separated list of endpoint parameter parameters specific DNS records"
  type        = string
  default     = null
  validation {
    condition     = var.svc_priority != 0
    error_message = "Not allowed if service priority is 0."
  }
}

variable "svc_priority" {
  description = "Service priority for specific DNS records"
  type        = number
  default     = null
  validation {
    condition     = var.svc_priority >= 0 && var.svc_priority <= 65535
    error_message = "The svc_priority must be a value between 0 and 65535, inclusive."
  }
}

variable "target_name" {
  description = "Target name for specific DNS records"
  type        = string
  default     = null
}

variable "type_bitmaps" {
  description = "List of type bitmaps for specific DNS records"
  type        = string
  default     = null
}

variable "type_covered" {
  description = "Type covered for specific DNS records"
  type        = number
  default     = null
}

variable "type_mnemonic" {
  description = "Type mnemonic for specific DNS records, e.g., 'PKIX-TA', 'SPKI-TA', etc."
  type        = string
  default     = null
}

variable "type_value" {
  description = "Type value for specific DNS records, e.g., 1 for PKIX-TA, 2 for SPKI-TA, etc."
  type        = number
  default     = null
}

variable "txt" {
  description = "TXT data for specific DNS records"
  type        = string
  default     = null
}

variable "usage" {
  description = "Usage for specific DNS records"
  type        = number
  default     = null
}

variable "weight" {
  description = "Weight for specific DNS records"
  type        = number
  default     = null
  validation {
    condition     = var.weight >= 0 && var.weight <= 65535
    error_message = "The weight must be a value between 0 and 65535, inclusive."
  }
}
