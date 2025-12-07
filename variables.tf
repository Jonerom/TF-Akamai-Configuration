variable "akamai_map" {
  description = "The complete Akamai Map configuration to configure the CDN solution for a single zone"
  type = map(object({
    akamai_group_name = string # Name of the Akamai Group assigned to the contract
    ##  DNS Configuration  ##
    # Configuration for each DNS Zone to be created
    zone_configuration = map(object({
      zone_name                = string           # DNS Zone name. Only letters, numbers, underscores (_), dots (.), and hyphens (-) are allowed. eg. example.com
      type                     = string           # Possible values are "primary", "secondary" or "alias"
      end_customer_id          = optional(string) # End Customer free-form identifier,ex. for reseller contracts
      comment                  = optional(string) # Comment for the DNS Zone
      sign_and_serve           = optional(bool)   # Sign and Serve enabled/disabled
      sign_and_serve_algorithm = optional(string) # Possible values are "hmac-sh
      outbound_zone_transfer = optional(object({  # Outbound Zone Transfer enabled/disabled
        enabled        = bool                     # Enable/Disable Outbound Zone Transfer
        acl            = list(string)             # List of IP addresses allowed to transfer the zone
        notify_targets = list(string)             # List of IP addresses to be notified of zone changes
        tsig_key = optional(object({              #  TSIG Key for Outbound Zone Transfer
          name      = string                      # TSIG Key name
          algorithm = string                      # TSIG Key algorithm
          secret    = string                      # TSIG Key secret
        }))
      }))
      masters = optional(list(string)) # List of Master IP addresses for Secondary zones
      tsig_key = optional(object({     # TSIG Key for Secondary zones
        name      = string             # TSIG Key name
        algorithm = string             # TSIG Key algorithm
        secret    = string             # TSIG Key secret
      }))
      target = optional(string) # Target zone for Alias zones
    }))
    ##  Non-Property DNS Configuration  ##
    # Mainly for external or non managed records, organized by zones
    non_property_dns_configuration = optional(map(object({
      zone = string # Zone name in which the DNS records will be created
      ### List of DNS records to be created in the zone
      # Find list of valid types and their required fields at:
      # https://techdocs.akamai.com/dns/docs/akamai-dns-record
      # possible to add any type supported by Akamai DNS by changing the module in the main.tf to dns-records-all
      # current setup supports most common types via dns-records module (A, AAAA, CNAME, MX, TXT, AKAMAICDN)
      records = list(object({
        name       = string           # DNS record name (e.g., www)
        type       = string           # DNS record type (e.g., A, CNAME, MX, AKAMAICDN, AKAMAITLC, TXT)
        targets    = list(string)     # DNS record target values (IPs, domain names, etc.) varies by record type
        ttl        = optional(number) # DNS record TTL in seconds (If not set, default value will be used)
        priority   = optional(number) # DNS record priority if applicable to all targets, else don't set
        type_value = optional(number) # DNS record type value
      }))
    })))
    ##  Web Security Configuration  ##
    # Setup of Web Security properties including WAF, Bot Manager, etc.
    # security_configuration = optional(map(object({ (not implemented yet WIP)    
    ##  Site Shield Configuration  ##
    # Configuration for each Site Shield to be created
    # Beware limited number of site shields per contract  
    # site_shield_configuration = optional(map(object({ (not implemented yet WIP)    
    ##  Custom Content Provider Configuration  ##
    # Content Provider configuration for custom billing managament
    # Only required if you prefer tu use a custom organization of CP codes
    # ignore for properties based CP Codes
    custom_content_provider_configuration = optional(map(object({
      product_id = string           # Akamai Product ID. see details at https://techdocs.akamai.com/terraform/docs/common-identifiers#product-ids
      cp_name    = string           # CP Name. Only letters, numbers, spaces, dots (.), and hyphens (-) are allowed
      timeout    = optional(string) # Timeout for CP Code update operations to override default 20m
    })))
    ## Properties Configuration  ##
    # Configuration for each Property to be created
    property_configuration = optional(map(object({
      property_name     = string           # Property name. Only letters, numbers, underscores (_), dots (.), and hyphens (-) are allowed
      product_id        = string           # Akamai Product ID. see details at https://techdocs.akamai.com/terraform/docs/common-identifiers#product-ids
      cp_code_name      = string           # Name of the CP Code to be associated with the property
      site_shield_name  = optional(string) # Name of the Site Shield to be associated with the Property
      web_security_name = optional(string) # Name of the Web Security configuration to be associated with the Property


      # How many, split how???
      certificate_name                                  = optional(string)       # Name of the FQDN for the certificate
      certificate_acknowledge_pre_verification_warnings = optional(bool)         # Flag to acknowledge pre-verification warnings during certificate enrollment
      certificate_sans                                  = optional(list(string)) # List of Subject Alternative Names (SANs) for the certificate
      certificate_secure_network                        = optional(string)       # Flag to indicate whether to enable PCI compliant Secure Network for the certificate
      certificate_sni_only                              = optional(bool)         # Flag to indicate whether to enable SNI only for the certificate
      certificate_signature_algorithm                   = optional(string)       # Signature algorithm for the certificate
      certificate_allow_duplicate_common_name           = optional(bool)         # Flag to allow duplicate common names for the certificate
      certificate_chain_type                            = optional(string)       # Type of certificate chain to be used
      certificate_timeout_certificate_creation          = optional(string)       # Timeout for Certificate creation operations
      certificate_timeout_certificate_validation        = optional(string)       # Timeout for Certificate validation operations


      # How many, which ones???
      edge_hostname_affix               = optional(string)       # Affix to identify the name to be used in the edge hostname
      edge_hostname_type                = optional(string)       # Type to be used in the Edge Hostname, possible values: enhanced, standard, shared or non-tls
      edge_hostname_ip_behavior         = optional(string)       # IP Behavior to be used by the Edge Hostname, possible values: IPV_4 or IPV6_COMPLIANCE / IPV6_PERFORMANCE
      edge_hostname_ttl                 = optional(number)       # TTL to be used in the Edge Hostname
      edge_hostname_status_update_email = optional(list(string)) # Status update email list to inform of the Edge Hostname changes
      edge_hostname_timeout             = optional(string)       # Timeout for Edge Hostname update operations to override default 20m




      origin_type         = string                 # Origin Type: "CUSTOMER", "AKAMAI", "CLOUDFRONT", "AZURE", "GCP", "S3"
      staging_network     = optional(string)       # Staging network to be used: "AKAMAI", "INTERNAL", "EXTERNAL"
      production_network  = optional(string)       # Production network to be used: "AKAMAI", "INTERNAL", "EXTERNAL"
      waf_profile         = optional(string)       # WAF Profile name to be associated with the property
      bot_manager_profile = optional(string)       # Bot Manager Profile name to be associated with the property
      rules               = optional(list(string)) # List of additional rules to be included in the property
    })))
  }))
}

variable "organization_details" {
  description = "Organization details for certificate creation if required"
  type = optional(object({
    ## Organization details ##
    organization = object({
      name             = string                 # Organization name
      phone            = string                 # Organization phone number
      country_code     = string                 # Organization country code
      region           = string                 # Organization region
      city             = string                 # Organization city
      address_line_one = string                 # Organization address line one
      address_line_two = optional(string, null) # Organization address line two
      postal_code      = string                 # Organization postal code
    })
    ## Admin contact ##
    # optional values default to organization values if not set
    admin_contact = object({
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
    ## Tech contact ##
    # optional values default to organization values if not set
    tech_contact = object({
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
    ## Certificate CSR details ##
    # optional values default to organization values if not set
    certificate_csr = object({
      preferred_trust_chain = optional(string, null) # Preferred trust chain for the certificate
      country_code          = optional(string, null) # CSR country code
      state                 = optional(string, null) # CSR state
      city                  = optional(string, null) # CSR city
      organization          = optional(string, null) # CSR organization
      organizational_unit   = optional(string, null) # CSR organizational unit
    })
  }))
  default = null
}
