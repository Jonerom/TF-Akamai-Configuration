variable "akamai_map" {
  description = "The complete Akamai Map configuration to configure the CDN solution for a single zone"
  type = object({
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
    # Only required if you prefer tu use a custom organization of CP codes, ignore for properties based CP Codes
    custom_content_provider_configuration = optional(map(object({
      product_id = string           # Akamai Product ID. see details at https://techdocs.akamai.com/terraform/docs/common-identifiers#product-ids
      cp_name    = string           # CP Name. Only letters, numbers, spaces, dots (.), and hyphens (-) are allowed
      timeout    = optional(string) # Timeout for CP Code update operations to override default 20m
    })))
    ## Properties Configuration  ##
    # Configuration for each Property to be created
    property_configuration = optional(map(object({
      property_name       = string           # Property name. Only letters, numbers, underscores (_), dots (.), and hyphens (-) are allowed
      support_team_emails = list(string)     # Email address(es) of the support team(s) for notifications related to the Property activations
      product_id          = string           # Akamai Product ID. see details at https://techdocs.akamai.com/terraform/docs/common-identifiers#product-ids
      version_note        = optional(string) # Version note for the Property
      activation_note     = optional(string) # Activation note for the Property
      custom_cp_name      = optional(string) # Name of the custom CP Code to be associated with the property. If not set, a new CP Code will be created
      ### Security Configurations ###
      site_shield_name  = optional(string) # Name of the Site Shield to be associated with the Property, recomended for WAF activated properties
      web_security_name = optional(string) # Name of the Web Security configuration to be associated with the Property
      ### Rule Configurations ###
      rule_format = optional(string) # Rule format for the Property. Possible values: 'latest' or see specific values: https://techdocs.akamai.com/terraform/docs/pm-ds-rule-formatsº
      # Recommendation is to customize rules via additional_json_rules but basict_json_rules can provide an easier way to get started
      default_json_rule_values = optional(object({
        comments    = optional(string)
        origin_type = string # Origin type for the default origin behavior, possible values: CUSTOMER, NET_STORAGE or AKAMAI_OBJECT_STORAGE
        # CUSTOMER origin type values
        forward_host_header           = optional(string) # Sets the Host header sent to the origin server, possible values: REQUEST_HOST_HEADER, ORIGIN_HOSTNAME or CUSTOM
        custom_forward_host_header    = optional(string) # Host header value when forward_host_header is set to CUSTOM
        cache_key_hostname            = optional(string) # Hostname used in the cache key, possible values: REQUEST_HOST_HEADER or ORIGIN_HOSTNAME
        ip_version                    = optional(string) # IP version used to connect to the origin, possible values: IPV4, IPV6 or DUAL_STACK
        compress                      = optional(bool)   # Flag to enable gzip compression between Akamai and the origin
        enable_true_client_ip         = optional(bool)   # Flag to enable True-Client-IP header to be sent to the origin
        true_client_ip_header         = optional(string) # Name of the True-Client-IP header sent to the origin when enable_true_client_ip is true
        true_client_ip_client_setting = optional(bool)   # Flag to enable client setting for True-Client-IP header when enable_true_client_ip is true
        http_port                     = optional(number) # Origin HTTP port
        https_port                    = optional(number) # Origin HTTPS port
        min_tls_version               = optional(string) # Minimum TLS version for HTTPS connections to the origin, possible values: TLSV1_1, TLSV1_2, TLSV1_3 or DYNAMIC
        origin_sni                    = optional(bool)   # Flag to enable SNI for HTTPS connections to the origin
        verification_mode             = optional(string) # Origin certificate verification mode, possible values: PLATFORM_SETTINGS, THIRD_PARTY or CUSTOM
        custom_valid_cn_values        = optional(string) # Custom common name values for origin certificate verification when verification_mode is CUSTOM
        origin_certs_to_honor         = optional(string) # Origin certificates to honor when verification_mode is CUSTOM, possible values: COMBO (all), STANDARD_​CERTIFICATE_​AUTHORITIES, CUSTOM_​CERTIFICATE_​AUTHORITIES	 or CUSTOM_​CERTIFICATES
        # NET_STORAGE origin type values
        net_storage = optional(object({
          account_id   = string           # NetStorage account ID
          origin_host  = string           # NetStorage origin hostname
          use_sps      = optional(bool)   # Flag to use Secure Path Service (SPS) for NetStorage origin authentication
          sps_key_name = optional(string) # SPS key name for NetStorage origin authentication when use_sps is true
        }))
        # AKAMAI_OBJECT_STORAGE origin type values
        akamai_object_storage = optional(object({
          container_name = string # Akamai Object Storage container name
          origin_host    = string # Akamai Object Storage origin hostname
        }))
        # Caching behavior values
        caching_behavior      = optional(string) # Caching behavior option in the mandatory rules, possible values: "NO_STORE", "BYPASS_CACHE", "MAX_AGE", "EXPIRES", "CACHE_CONTROL" or "CACHE_CONTROL_AND_EXPIRES"
        must_revalidate       = optional(bool)   # Flag to set the Must-Revalidate directive in the caching behavior of the mandatory rules, valid only for "MAX_AGE", "EXPIRES", "CACHE_CONTROL" and "CACHE_CONTROL_AND_EXPIRES"
        ttl                   = optional(string) # TTL value in for the caching behavior of the mandatory rules (eg: 30s, 1m, 2h), valid only for "MAX_AGE","EXPIRES", "CACHE_CONTROL" and "CACHE_CONTROL_AND_EXPIRES"
        enhanced_rfc_support  = optional(bool)   # Flag to enable enhanced RFC compliance in the caching behavior of the mandatory rules, valid only for "CACHE_CONTROL" and "CACHE_CONTROL_AND_EXPIRES"
        honor_private         = optional(bool)   # Flag to honor private caching directives in the caching behavior of the mandatory rules, valid only for "CACHE_CONTROL" and "CACHE_CONTROL_AND_EXPIRES"
        honor_must_revalidate = optional(bool)   # Flag to honor must-revalidate directives in the caching behavior of the mandatory rules, valid only for "CACHE_CONTROL" and "CACHE_CONTROL_AND_EXPIRES"
      }))
      basic_json_rules      = optional(bool)         # Flag to indicate whether to use basic JSON rules for the Property if additional_json_rules is not set
      additional_json_rules = optional(list(string)) # List of additional JSON rules to be merged into the default Property rules
      ### Activation Configurations ###
      auto_acknowledge_rule_warnings_staging    = optional(bool)   # Flag to auto acknowledge rule warnings during staging activation
      auto_acknowledge_rule_warnings_production = optional(bool)   # Flag to auto acknowledge rule warnings during production activation
      timeout_staging_activation                = optional(string) # Timeout for Property's staging activation operation
      timeout_production_activation             = optional(string) # Timeout for Property's production activation operation
      ### Certificate Configurations ###
      # General configuration for the certificate
      # A name is mandatory for certificate creation,other values, if not set, default behavior will be used
      certificate_general_configuration = optional(object({
        certificate_name                      = (string)         # Name of certificate to be created, mandatory for WAF enabled properties
        acknowledge_pre_verification_warnings = optional(bool)   # Flag to acknowledge pre-verification warnings during certificate enrollment
        secure_network                        = optional(string) # Flag to indicate whether to enable PCI compliant Secure Network for the certificate
        sni_only                              = optional(bool)   # Flag to indicate whether to enable SNI only for the certificate
        signature_algorithm                   = optional(string) # Signature algorithm for the certificate
        allow_duplicate_common_name           = optional(bool)   # Flag to allow duplicate common names for the certificate
        chain_type                            = optional(string) # Type of certificate chain to be used
        timeout_certificate_creation          = optional(string) # Timeout for Certificate creation operations
        timeout_certificate_validation        = optional(string) # Timeout for Certificate validation operations
      }))
      # Network configuration for the certificate
      # if not set, default behavior will be used
      certificate_network_configuration = optional(object({
        disallowed_tls_versions = optional(list(string)) # List of disallowed TLS versions for the certificate network configuration
        clone_dns_names         = optional(bool)         # Flag to enable the certificate provisioning system directs traffic using all the SANs listed at the time of enrollment creation. null uses default behavior
        geography               = optional(string)       # Geography for the certificate network configuration. Possible values are 'core', 'china+core' or 'russia+core'
        ocsp_stapling           = optional(string)       # OCSP Stapling setting for the certificate network configuration. Possible values are 'on', 'off' or 'not-set'
        preferred_ciphers       = optional(string)       # Preferred ciphers for the certificate network configuration.
        must_have_ciphers       = optional(string)       # Must have ciphers for the certificate network configuration.
        quic_enabled            = optional(bool)         # Flag to enable QUIC for the certificate network configuration.
      }))
      ### Edge Hostname Configuration ###
      # Configuration for the Edge Hostname associated with the Property
      # A name affix is mandatory for certificate creation,other values, if not set, default behavior will be used
      edge_hostname_configuration = optional(object({
        hostname_affix = string           # Affix to identify the function or usage in the edge hostname
        type           = optional(string) # Type to be used in the Edge Hostname, possible values: enhanced, standard, shared or non-tls
        ip_behavior    = optional(string) # IP Behavior to be used by the Edge Hostname, possible values: IPV_4 or IPV6_COMPLIANCE / IPV6_PERFORMANCE
        ttl            = optional(number) # TTL to be used in the Edge Hostname
        timeout        = optional(string) # Timeout for Edge Hostname update operations to override default 20m
        use_cases = optional(list(object({
          option   = string
          type     = string
          use_case = string
        })))
      }))
      ### DNS Records Configuration ###
      # All dns records associated with the property, organized by zones
      # keep empty "" for root domain as akamai does not support @
      host_configuration = map(object({
        zone = string                               # DNS Zone name. Only letters, numbers, underscores (_), dots (.), and hyphens (-) are allowed. eg. example.com
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
    })))
  })
}

# Organization Details #
# Mandatory for certificate creation
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
    certificate_csr = optional(object({
      preferred_trust_chain = optional(string, null) # Preferred trust chain for the certificate
      country_code          = optional(string, null) # CSR country code
      state                 = optional(string, null) # CSR state
      city                  = optional(string, null) # CSR city
      organization          = optional(string, null) # CSR organization
      organizational_unit   = optional(string, null) # CSR organizational unit
    }))
  }))
  default = null
}
