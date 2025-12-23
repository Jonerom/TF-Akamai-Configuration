variable "akamai_map" {
  description = "The complete Akamai Map configuration to configure the CDN solution for a single zone"
  type = object({
    akamai_group_name = string # Name of the Akamai Group assigned to the contract
    ##  DNS Configuration  ##
    # Configuration for each DNS Zone to be created
    zone_configuration = map(object({
      zone_name                = string           # DNS Zone name. Only letters, numbers, underscores (_), dots (.), and hyphens (-) are allowed. eg. example.com
      type                     = optional(string) # Possible values are "primary", "secondary" or "alias"
      end_customer_id          = optional(string) # End Customer free-form identifier,ex. for reseller contracts
      comment                  = optional(string) # Comment for the DNS Zone
      sign_and_serve           = optional(bool)   # Sign and Serve enabled/disabled
      sign_and_serve_algorithm = optional(string) # Possible values are "hmac-sh
      outbound_zone_transfer = optional(object({  # Outbound Zone Transfer enabled/disabled
        enabled        = bool                     # Enable/Disable Outbound Zone Transfer
        acl            = list(string)             # List of IP addresses allowed to transfer the zone
        notify_targets = list(string)             # List of IP addresses to be notified of zone changes
      }))
      outbound_zone_transfer_tsig_key = optional(object({ # TSIG Key for Outbound Zone Transfer
        name      = string                                # TSIG Key name
        algorithm = string                                # TSIG Key algorithm
        secret    = string                                # TSIG Key secret - do not store in version control (use sensitive variables or secret manager instead)
      }))
      masters = optional(list(string)) # List of Master IP addresses for Secondary zones
      tsig_key = optional(object({     # TSIG Key for Secondary zones
        name      = string             # TSIG Key name
        algorithm = string             # TSIG Key algorithm
        secret    = string             # TSIG Key secret - do not store in version control (use sensitive variables or secret manager instead)
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
    # Setup of Web Security configuration main settings
    security_configuration = optional(object({
      name                  = string                           # Name of the Web Security configuration to be created
      activation_note       = optional(string)                 # Activation note for the Property
      description           = optional(string)                 # Description of the Web Security configuration
      support_team_emails   = list(string)                     # Email address(es) of the support team(s) for notifications related to the Property activations
      create_from_config_id = optional(string)                 # The configuration ID to create this configuration from
      create_from_version   = optional(number)                 # The version of the configuration to create this configuration
      config_settings = optional(object({                      # Establish configuration settings
        evasive_path_match_enable     = optional(bool)         # Enable Evasive URL Request Matching
        prefetch_enable_app_layer     = optional(bool)         # Enable Prefetch Requests for Application Layer
        prefetch_all_extensions       = optional(bool)         # Prefetch Requests for All Extensions if prefetch_enable_app_layer is true
        prefetch_extensions           = optional(list(string)) # List of Extensions for Prefetch Requests if prefetch_all_extensions is false and prefetch_enable_app_layer is true it must be empty []
        prefetch_enable_rate_controls = optional(bool)         # Enable Rate Controls for Prefetch Requests
        request_body_inspection_limit = optional(string)       # Request size inspection limit in KB, possible values: default, 8, 16, 32
        pii_learning_enable           = optional(bool)         # Enable API PII learning
        http_logging = optional(object({                       # Establish HTTP header data logging configuration
          enabled       = optional(string)                     # Enable HTTP header logging
          cookies       = optional(string)                     # Cookie headers to log, possible values: all, none, exclude, only
          custom_type   = optional(string)                     # Custom headers to log, possible values: all, none, exclude, only
          standard_type = optional(string)                     # Standard headers to log, possible values: all, none, exclude, only
        }))
        attack_payload_logging = object({  # Establish Attack payload logging configuration
          enabled       = optional(string) # Enable Attack payload logging
          request_body  = optional(string) # Log request body, possible values: NONE or ATTACK_PAYLOAD
          response_body = optional(string) # Log response body, possible values: NONE or ATTACK_PAYLOAD
        })
        siem_settings_enable         = optional(bool)         # Enable SIEM integration
        siem_enable_for_all_policies = optional(bool)         # Enable SIEM integration for all security policies
        siem_security_policy_ids     = optional(list(string)) # List of security policy IDs to enable SIEM integration for, if siem_enable_for_all_policies is false it must be empty []
        siem_id                      = optional(number)       # SIEM integration ID to use
        siem_include_ja4_fingerprint = optional(bool)         # Include JA4 fingerprint in SIEM logs
        siem_exception_list = optional(list(object({          # Establish SIEM Exception List configuration
          api_request_constraints = optional(set(string))     # Establish API Request Constraints for SIEM Exception List
          apr_protection          = optional(set(string))     # Establish APR Protection for SIEM Exception List
          bot_management          = optional(set(string))     # Establish Bot Management for SIEM Exception List
          client_rep              = optional(set(string))     # Establish Client Reputation for SIEM Exception List
          custom_rules            = optional(set(string))     # Establish Custom Rules for SIEM Exception List
          ip_geo                  = optional(set(string))     # Establish IP Geo for SIEM Exception List
          malware_protection      = optional(set(string))     # Establish Malware Protection for SIEM Exception List
          rate                    = optional(set(string))     # Establish Rate for SIEM Exception List
          slow_post               = optional(set(string))     # Establish Slow Post for SIEM Exception List
          url_protection          = optional(set(string))     # Establish URL Protection for SIEM Exception List
          waf                     = optional(set(string))     # Establish WAF for SIEM Exception List
        })))
        pragma_header = object({                          # Establish Strip Pragma debug headers from responses configuration
          action                 = optional(string)       # Action to apply to Pragma debug headers, possible values: REMOVE
          conditional_operator   = optional(string)       # Condition operator for excluding certain requests from header removal, possible values: AND (ALL), OR (ANY)
          exclude_condition_list = optional(list(string)) # List of conditions to exclude from header removal, find details at https://techdocs.akamai.com/application-security/reference/put-advanced-settings-pragma-header
        })
      }))
    }))
    # Setup of Web Security policies including WAF, Bot Manager, etc.
    security_policy = optional(map(object({
      name                           = string           # Name of the Web Security policy to be created
      policy_prefix                  = optional(string) # Prefix for the security policy name, value has to be 4 chars long
      default_settings               = optional(bool)   # Assign default Akamai security policy settings or create a blank policy
      create_from_security_policy_id = optional(string) # The security policy ID to create this policy from
      policy_settings = optional(object({               # Establish policy settings
        match_target = map(object({                     # Map of match targets to apply the policy to
          # Each must contain a type and either the apis object block or the website object block
          type = optional(string, "website")                          # Type of match target, possible values are: website or api
          website = optional(object({                                 # Website match target settings (only for website type)
            default_file                     = optional(string)       # Rule to match on paths, possible values are: NO_MATCH (custom), BASE_MATCH (top-level w/ trailing slash)or RECURSIVE_MATCH (all w/ trailing slash)
            file_extension_list              = optional(list(string)) # List of file extensions to match on
            file_path_list                   = optional(list(string)) # List of file paths to match on
            hostname_list                    = optional(list(string)) # List of hostnames to match on
            is_negative_file_extension_match = optional(string)       # File extension matching query, possible values are: true = NOT match // false = match
            is_negative_path_match           = optional(string)       # File path matching query, possible values are: true = NOT match // false = match
            bypass_network_list              = optional(string)       # Network list to bypass the match target
          }))
          apis = optional(list(object({ # List of APIs to match on (only for API type)
            api_id   = optional(string) # API ID to match on
            api_name = optional(string) # API name to match on
          })))
        }))
        override_evasive_path         = optional(bool)   # Whether to override default configuration settings for evasive path matching
        evasive_path_match_enable     = optional(bool)   # Enable Evasive URL Request Matching if override_evasive_path is true
        override_request_body         = optional(bool)   # Whether to override default configuration settings for request body inspection
        request_body_inspection_limit = optional(string) # Request size inspection limit in KB, possible values: default, 8, 16, 32 if override_request_body is true
        http_logging = optional(object({                 # Override default HTTP header data logging configuration
          override      = optional(bool)                 # Whether to override the default HTTP logging settings
          enabled       = optional(string)               # Enable HTTP header logging
          cookies       = optional(string)               # Cookie headers to log, possible values: all, none, exclude, only
          custom_type   = optional(string)               # Custom headers to log, possible values: all, none, exclude, only
          standard_type = optional(string)               # Standard headers to log, possible values: all, none, exclude, only
        }))
        attack_payload_logging = object({  # Override default Attack payload logging configuration
          override      = optional(string) # Whether to override the default attack payload logging settings
          enabled       = optional(string) # Enable Attack payload logging
          request_body  = optional(string) # Log request body, possible values: NONE or ATTACK_PAYLOAD
          response_body = optional(string) # Log response body, possible values: NONE or ATTACK_PAYLOAD
        })
        pragma_header = object({                          # Override default Pragma header configuration
          override               = optional(string)       # Whether to override the default Pragma header settings
          action                 = optional(string)       # Pragma header action, possible values: ADD, REMOVE, NONE
          conditional_operator   = optional(string)       # Conditional operator for the pragma header, possible values: AND, OR
          exclude_condition_list = optional(list(string)) # List of conditions to exclude the pragma header
        })
        ip_geo_protection_enable = optional(bool)   # Enable IP/Geo Firewall
        ip_geo_mode              = optional(string) # IP/Geo Firewall mode, possible values are: allow, block
        asn_network_lists = optional(object({       # Object containing ASN network lists and action to apply
          asn_network_lists = list(string), action = string
        }))
        geo_network_lists = optional(object({ # Object containing Geo network lists and action to apply
          geo_network_lists = list(string), action = string
        }))
        ip_network_lists = optional(object({ # Object containing IP network lists and action to apply
          ip_network_lists = list(string), action = string
        }))
        exception_ip_network_lists = optional(list(string))  # List of exception IP network lists
        ukraine_geo_control_action = optional(string)        # Action for Ukraine Geo Control, possible values are: alert, deny, none
        dos_rate_protection_enable = optional(bool, true)    # Enable DoS Rate Protection
        dos_rate_policy = optional(object({                  # DoS Rate Protection policy settings
          ipv4_action           = optional(string)           # Action for IPv4 DoS Rate Protection, possible values are: deny, alert
          ipv6_action           = optional(string)           # Action for IPv6 DoS Rate Protection, possible values are: deny, alert
          file_path             = optional(string)           # File path for custom rate limiting settings
          rate_policy_file_list = optional(list(string), []) # List of additional rate policy files to include
        }))
        dos_slowpost_protection_enable    = optional(bool)             # Enable DoS Slow Post Protection
        dos_slow_rate_action              = optional(string)           # Action for DoS Slow Rate Protection, possible values are: abort, alert
        dos_slow_rate_threshold_rate      = optional(number)           # Threshold rate for DoS Slow Rate Protection
        dos_slow_rate_threshold_period    = optional(number)           # Threshold period for DoS Slow Rate Protection
        dos_duration_threshold_timeout    = optional(number)           # Duration threshold timeout for DoS Slow Post Protection
        waf_protection_enable             = optional(bool)             # Enable Web Application Firewall
        waf_mode                          = optional(string)           #  WAF mode, possible values are: ASE_AUTO / AAG = Akamai updated // ASE_MANUAL / KRS = manually updated
        waf_attack_group_action_cmdi      = optional(string)           # Action for Command Injection attack group, possible values are: deny, alert, not used
        waf_attack_group_action_xss       = optional(string)           # Action for Cross-Site Scripting attack group, possible values are: deny, alert, not used
        waf_attack_group_action_lfi       = optional(string)           # Action for Local File Inclusion attack group, possible values are: deny, alert, not used
        waf_attack_group_action_rfi       = optional(string)           # Action for Remote File Inclusion attack group, possible values are: deny, alert, not used
        waf_attack_group_action_sql       = optional(string)           # Action for SQL Injection attack group, possible values are: deny, alert, not used
        waf_attack_group_action_to        = optional(string)           # Action for Outbound attack group, possible values are: deny, alert, not used
        waf_attack_group_action_wat       = optional(string)           # Action for Web Application Threats attack group, possible values are: deny, alert, not used
        waf_attack_group_action_wpla      = optional(string)           # Action for Platform attack group, possible values are: deny, alert, not used
        waf_attack_group_action_wpv       = optional(string)           # Action for Policy Violations attack group, possible values are: deny, alert, not used
        waf_attack_group_action_wpra      = optional(string)           # Action for Protocol attack group, possible values are: deny, alert, not used
        waf_penalty_box_enable            = optional(bool)             # Enable WAF Penalty Box
        waf_penalty_box_action            = optional(string)           # Action for WAF Penalty Box, possible values are: deny, alert, not used
        api_constraints_enable            = optional(bool)             # Enable API Constraints
        reputation_protection_enable      = optional(bool)             # Enable Reputation Protection
        reputation_profile_default        = optional(list(string), []) # List of default reputation profiles to include
        reputation_profile_default_action = optional(string)           # Action for default reputation profiles, possible values are: alert, deny
        reputation_profile = optional(list(object({                    # List of custom reputation profiles to include
          name               = optional(string)                        # Name of the reputation profile
          action             = optional(string)                        # Action for the reputation profile, possible values are: alert, deny
          context            = optional(string)                        #  Context for the reputation profile, possible values are: WEBATCK, DOSATCK, WEBSCRP, SCANTL
          shared_ip_handling = optional(string)                        # Shared IP handling for the reputation profile, possible values are: NON_SHARED, SHARED_ONLY, BOTH
          threshold          = optional(string)                        # Threshold for the reputation profile
        })))
        client_forward_to_http_header                = optional(bool) # Enable Client IP forwarding to HTTP header
        client_forward_shared_ip_to_http_header_siem = optional(bool) # Enable Client IP forwarding for shared IPs to HTTP header for SIEM
        bot_management_settings = object({                            # Bot Management settings
          enable_bot_management                   = optional(bool)    # Enable Bot Management
          add_akamai_bot_header                   = optional(bool)    # Add Akamai Bot header to requests
          third_party_proxy_service_in_use        = optional(bool)    # Indicate if a third-party proxy service is in use
          remove_bot_management_cookies           = optional(bool)    # Remove Bot Management cookies from responses
          enable_active_detections                = optional(bool)    # Enable active detections for Bot Management
          enable_browser_validation               = optional(bool)    # Enable browser validation for Bot Management
          include_transactional_endpoint_requests = optional(bool)    # Include transactional endpoint requests in Bot Management
          include_transactional_endpoint_status   = optional(bool)    # Add Akamai Bot header to requests to all transactional endpoints
        })
        custom_bot_path = optional(string)           # Path to custom bot definitions
        custom_bot_category = optional(list(object({ # List of custom bot categories
          category_name = optional(string)           # Name of the custom bot category
          action        = optional(string)           # Action for the custom bot category, possible values are: monitor, tarpit, slow, deny
          bots          = optional(list(string))     # List of bots in the custom bot category
        })))
        bot_category_action = object({                                # Akamai Bot category actions, possible values are: monitor, tarpit, slow, deny, delay, skip
          academic_or_research_bots                = optional(string) # Action for Academic or Research bots
          artificial_intelligence_ai_bots          = optional(string) # Action for Artificial Intelligence (AI) bots
          automated_shopping_cart_and_sniper_bots  = optional(string) # Action for Automated Shopping Cart and Sniper bots
          business_intelligence_bots               = optional(string) # Action for Business Intelligence bots
          ecommerce_search_engine_bots             = optional(string) # Action for Ecommerce Search Engine bots
          enterprise_data_aggregator_bots          = optional(string) # Action for Enterprise Data Aggregator bots
          financial_account_aggregator_bots        = optional(string) # Action for Financial Account Aggregator bots
          financial_services_bots                  = optional(string) # Action for Financial Services bots
          job_search_engine_bots                   = optional(string) # Action for Job Search Engine bots
          media_or_entertainment_search_bots       = optional(string) # Action for Media or Entertainment Search bots
          news_aggregator_bots                     = optional(string) # Action for News Aggregator bots
          online_advertising_bots                  = optional(string) # Action for Online Advertising bots
          rss_feed_reader_bots                     = optional(string) # Action for RSS Feed Reader bots
          seo_analytics_or_marketing_bots          = optional(string) # Action for SEO Analytics or Marketing bots
          site_monitoring_and_web_development_bots = optional(string) # Action for Site Monitoring and Web Development bots
          social_media_or_blog_bots                = optional(string) # Action for Social Media or Blog bots
          web_archiver_bots                        = optional(string) # Action for Web Archiver bots
          web_search_engine_bots                   = optional(string) # Action for Web Search Engine bots
        })
        bot_detection_action = object({                              # Akamai Bot transparent detection actions, possible values are: monitor, tarpit, slow, deny, delay, skip
          impersonators_of_known_bots             = optional(string) # Action for Impersonators of Known bots
          development_frameworks                  = optional(string) # Action for Development Frameworks
          http_libraries                          = optional(string) # Action for HTTP Libraries
          web_services_libraries                  = optional(string) # Action for Web Services Libraries
          open_source_crawlers_scraping_platforms = optional(string) # Action for Open Source Crawlers and Scraping Platforms
          headless_browsers_automation_tools      = optional(string) # Action for Headless Browsers and Automation Tools
          declared_bots                           = optional(string) # Action for Declared bots
          aggressive_web_crawlers                 = optional(string) # Action for Aggressive Web Crawlers
          browser_impersonator                    = optional(string) # Action for Browser Impersonators
          webscraper_reputation_action            = optional(string) # Action for Webscraper Reputation
          webscraper_reputation_sensitivity       = optional(number) # Sensitivity for Webscraper Reputation, possible values are: 1 (most sensitive) to 10 (least sensitive)
          cookie_integrity_failed                 = optional(string) # Action for Cookie Integrity Failed
          session_validation_action               = optional(string) # Action for Session Validation
          session_validation_sensitivity          = optional(string) # Sensitivity for Session Validation, possible values are: LOW, MEDIUM, HIGH
          client_disabled_javascript              = optional(string) # Action for Client Disabled Javascript
          javascript_fingerprint_anomaly          = optional(string) # Action for Javascript Fingerprint Anomaly
          javascript_fingerprint_not_received     = optional(string) # Action for Javascript Fingerprint Not Received
        })
        inject_javascript = optional(string) # JavaScript injection timing, possible values are: AROUND_PROTECTED_OPERATIONS, NEVER, ALWAYS
      }))
    })))
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
      # site_shield_name  = optional(string) # Name of the Site Shield to be associated with the Property, recomended for WAF activated properties
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
