
variable "contract" {
  description = "Akamai Contract ID where the certificate will be created"
  type        = string
}

variable "name" {
  description = "Name of the FQDN for the certificate"
  type        = string
}

variable "acknowledge_pre_verification_warnings" {
  description = "Flag to acknowledge pre-verification warnings during certificate enrollment. null uses default behavior"
  type        = bool
  default     = null
}

## One of the either methods to specify SANs for the certificate must be provided
# Simple method to specify SANs as a list of records for a single zone
variable "zone" {
  description = "Zone where the dns record validation will be created"
  type        = string
  default     = ""
}
variable "sans" {
  description = "List of Subject Alternative Names (SANs) for the certificate for a single zone"
  type        = list(string)
  default     = []
}
# Complex method to specify SANs through a map of zones with records
variable "zone_sans_map" {
  description = "Map of zones with lists of records for Subject Alternative Names (SANs) for the certificate"
  type = map(object({
    zone_name = string
    records   = list(object({ name = string }))
  }))
  validation {
    condition     = (length(var.sans) > 0 && var.zone != "") || length(var.zone_sans_map) > 0
    error_message = "Either 'sans' list or 'zone_sans_map' must be provided with at least one SAN."
  }
  default = {}
}

variable "secure_network" {
  description = "Flag to indicate whether to enable PCI compliant Secure Network for the certificate, Options are 'standard-tls' non compliant or 'enhanced-tls' PCI compliant"
  type        = string
}

variable "sni_only" {
  description = "Flag to indicate whether to enable SNI only for the certificate"
  type        = bool
}

variable "signature_algorithm" {
  description = "Signature algorithm for the certificate, e.g., SHA-256"
  type        = string
  default     = "SHA-256"
}

variable "allow_duplicate_common_name" {
  description = "Flag to allow duplicate common names for the certificate. null uses default behavior"
  type        = bool
  default     = null
}

variable "certificate_chain_type" {
  description = "Type of certificate chain to be used. null uses default behavior"
  type        = string
  default     = null
}

variable "timeout_certificate_creation" {
  description = "Timeout for Certificate creation operations overriding default 20m"
  type        = string
  default     = null
}

variable "timeout_certificate_validation" {
  description = "Timeout for Certificate validation operations overriding default 20m"
  type        = string
  default     = null
}

variable "network_configuration" {
  description = "Network configuration settings for the certificate"
  type = object({
    disallowed_tls_versions = optional(list(string), ["TLSv1", "TLSv1_1"]) # List of disallowed TLS versions for the certificate network configuration
    clone_dns_names         = optional(bool, null)                         # Flag to enable the certificate provisioning system directs traffic using all the SANs listed at the time of enrollment creation. null uses default behavior
    geography               = optional(string, "core")                     # Geography for the certificate network configuration. Possible values are 'core', 'china+core' or 'russia+core'
    ocsp_stapling           = optional(string, null)                       # OCSP Stapling setting for the certificate network configuration. Possible values are 'on', 'off' or 'not-set'
    preferred_ciphers       = optional(string, null)                       # Preferred ciphers for the certificate network configuration. null uses default behavior
    must_have_ciphers       = optional(string, null)                       # Must have ciphers for the certificate network configuration. null uses default behavior
    quic_enabled            = optional(bool, null)                         # Flag to enable QUIC for the certificate network configuration. null uses default behavior
  })
}

variable "csr" {
  description = "Certificate Signing Request (CSR) details for the certificate unless different from Organizations details"
  type = optional(object({
    preferred_trust_chain = optional(string, null) # Preferred trust chain for the CSR
    country_code          = optional(string, null) # Country code for the CSR
    state                 = optional(string, null) # State or province for the CSR
    city                  = optional(string, null) # City for the CSR
    organization          = optional(string, null) # Organization name for the CSR
    organizational_unit   = optional(string, null) # Organizational unit for the CSR
  }))
}

variable "organization" {
  description = "Organization details for the certificate"
  type = object({
    name             = string                 # Organization name
    phone            = string                 # Organization phone number
    country_code     = string                 # Organization country code
    region           = string                 # Organization region
    city             = string                 # Organization city
    address_line_one = string                 # Organization address line one
    address_line_two = optional(string, null) # Organization address line two
    postal_code      = string                 # Organization postal code
  })
}

variable "admin_contact" {
  description = "Administrative contact details for the certificate, if different from Organization details"
  type = object({
    organization     = optional(string, null) # Admin contact organization
    title            = optional(string, null) # Admin contact title
    first_name       = string                 # Admin contact first name
    last_name        = string                 # Admin contact last name
    phone            = string                 # Admin contact phone number
    email            = string                 # Admin contact email address
    country_code     = optional(string, null) # Admin contact country code
    region           = optional(string, null) # Admin contact region
    city             = optional(string, null) # Admin contact city
    address_line_one = optional(string, null) # Admin contact address line one
    address_line_two = optional(string, null) # Admin contact address line two
    postal_code      = optional(string, null) # Admin contact postal code
  })
}

variable "tech_contact" {
  description = "Technical contact details for the certificate, if different from Organization details"
  type = object({
    organization     = optional(string, null) # Tech contact organization
    title            = optional(string, null) # Tech contact title
    first_name       = string                 # Tech contact first name
    last_name        = string                 # Tech contact last name
    phone            = string                 # Tech contact phone number
    email            = string                 # Tech contact email address
    country_code     = optional(string, null) # Tech contact country code
    region           = optional(string, null) # Tech contact region
    city             = optional(string, null) # Tech contact city
    address_line_one = optional(string, null) # Tech contact address line one
    address_line_two = optional(string, null) # Tech contact address line two
    postal_code      = optional(string, null) # Tech contact postal code
  })
}
