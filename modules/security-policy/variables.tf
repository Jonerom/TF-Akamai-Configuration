variable "config_id" {
  description = "The security configuration ID to apply the policy to."
  type        = string
}

variable "policy_name" {
  description = "Name for the security policy"
  type        = string
}

variable "policy_prefix" {
  description = "Prefix for the security policy name, value has to be 4 chars long"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{4}$", var.policy_prefix)) || var.policy_prefix == null
    error_message = "The policy_prefix must be exactly 4 alphanumeric characters (letters and numbers only)."
  }
  default = null
}

variable "default_settings" {
  type        = bool
  description = "Assign default Akamai security policy settings or create a blank policy"
  default     = false
}

variable "create_from_security_policy_id" {
  type        = string
  description = "ID of an existing security policy to copy from"
  default     = null
}

variable "security_policy" {
  description = "Security policies to setup on this config."
  type = object({
    match_target = map(object({ # Map of match targets to apply the policy to
      # Each must contain a type and either the apis object block or the website object block
      type = optional(string, "website")                                # Type of match target, possible values are: website or api
      website = optional(object({                                       # Website match target settings (only for website type)
        default_file                     = optional(string, "NO_MATCH") # Rule to match on paths, possible values are: NO_MATCH (custom), BASE_MATCH (top-level w/ trailing slash)or RECURSIVE_MATCH (all w/ trailing slash)
        file_extension_list              = optional(list(string), [])   # List of file extensions to match on
        file_path_list                   = optional(list(string), [])   # List of file paths to match on
        hostname_list                    = optional(list(string), [])   # List of hostnames to match on
        is_negative_file_extension_match = optional(string)             # File extension matching query, possible values are: true = NOT match // false = match
        is_negative_path_match           = optional(string)             # File path matching query, possible values are: true = NOT match // false = match
        bypass_network_list              = optional(string)             # Network list to bypass the match target
      }))
      apis = optional(list(object({ # List of APIs to match on (only for API type)
        api_id   = optional(string) # API ID to match on
        api_name = optional(string) # API name to match on
      })), [])
    }))
    override_evasive_path         = optional(bool, false) # Whether to override default configuration settings for evasive path matching
    evasive_path_match_enable     = optional(bool)        # Enable Evasive URL Request Matching if override_evasive_path is true
    override_request_body         = optional(bool, false) # Whether to override default configuration settings for request body inspection
    request_body_inspection_limit = optional(string)      # Request size inspection limit in KB, possible values: default, 8, 16, 32 if override_request_body is true
    http_logging = object({                               # Override default HTTP header data logging configuration
      override      = optional(bool, false)               # Whether to override the default HTTP logging settings
      enabled       = optional(string)                    # Enable HTTP header logging
      cookies       = optional(string)                    # Cookie headers to log, possible values: all, none, exclude, only
      custom_type   = optional(string)                    # Custom headers to log, possible values: all, none, exclude, only
      standard_type = optional(string)                    # Standard headers to log, possible values: all, none, exclude, only
    })
    attack_payload_logging = object({           # Override default Attack payload logging configuration
      override      = optional(string, "false") # Whether to override the default attack payload logging settings
      enabled       = optional(string)          # Enable Attack payload logging
      request_body  = optional(string)          # Log request body, possible values: NONE or ATTACK_PAYLOAD
      response_body = optional(string)          # Log response body, possible values: NONE or ATTACK_PAYLOAD
    })
    pragma_header = object({                             # Override default Pragma header configuration
      override               = optional(string, "false") # Whether to override the default Pragma header settings
      action                 = optional(string)          # Pragma header action, possible values: ADD, REMOVE, NONE
      conditional_operator   = optional(string)          # Conditional operator for the pragma header, possible values: AND, OR
      exclude_condition_list = optional(list(string))    # List of conditions to exclude the pragma header
    })
    ip_geo_protection_enable = optional(bool, true)      # Enable IP/Geo Firewall
    ip_geo_mode              = optional(string, "allow") # IP/Geo Firewall mode, possible values are: allow, block
    asn_network_lists = optional(object({                # Object containing ASN network lists and action to apply
      asn_network_lists = list(string), action = string
    }))
    geo_network_lists = optional(object({ # Object containing Geo network lists and action to apply
      geo_network_lists = list(string), action = string
    }))
    ip_network_lists = optional(object({ # Object containing IP network lists and action to apply
      ip_network_lists = list(string), action = string
    }))
    exception_ip_network_lists = optional(list(string))   # List of exception IP network lists
    ukraine_geo_control_action = optional(string, "none") # Action for Ukraine Geo Control, possible values are: alert, deny, none
    dos_rate_protection_enable = optional(bool, true)     # Enable DoS Rate Protection
    dos_rate_policy = optional(object({                   # DoS Rate Protection policy settings
      ipv4_action           = optional(string)            # Action for IPv4 DoS Rate Protection, possible values are: deny, alert
      ipv6_action           = optional(string)            # Action for IPv6 DoS Rate Protection, possible values are: deny, alert
      file_path             = optional(string)            # File path for custom rate limiting settings
      rate_policy_file_list = optional(list(string), [])  # List of additional rate policy files to include
    }), {})
    dos_slowpost_protection_enable    = optional(bool, true)         # Enable DoS Slow Post Protection
    dos_slow_rate_action              = optional(string, "abort")    # Action for DoS Slow Rate Protection, possible values are: abort, alert
    dos_slow_rate_threshold_rate      = optional(number, 10)         # Threshold rate for DoS Slow Rate Protection
    dos_slow_rate_threshold_period    = optional(number, 60)         # Threshold period for DoS Slow Rate Protection
    dos_duration_threshold_timeout    = optional(number)             # Duration threshold timeout for DoS Slow Post Protection
    waf_protection_enable             = optional(bool, true)         # Enable Web Application Firewall
    waf_mode                          = optional(string, "ASE_AUTO") #  WAF mode, possible values are: ASE_AUTO / AAG = Akamai updated // ASE_MANUAL / KRS = manually updated
    waf_attack_group_action_cmdi      = optional(string, "deny")     # Action for Command Injection attack group, possible values are: deny, alert, not used
    waf_attack_group_action_xss       = optional(string, "deny")     # Action for Cross-Site Scripting attack group, possible values are: deny, alert, not used
    waf_attack_group_action_lfi       = optional(string, "deny")     # Action for Local File Inclusion attack group, possible values are: deny, alert, not used
    waf_attack_group_action_rfi       = optional(string, "deny")     # Action for Remote File Inclusion attack group, possible values are: deny, alert, not used
    waf_attack_group_action_sql       = optional(string, "deny")     # Action for SQL Injection attack group, possible values are: deny, alert, not used
    waf_attack_group_action_to        = optional(string, "deny")     # Action for Outbound attack group, possible values are: deny, alert, not used
    waf_attack_group_action_wat       = optional(string, "deny")     # Action for Web Application Threats attack group, possible values are: deny, alert, not used
    waf_attack_group_action_wpla      = optional(string, "deny")     # Action for Platform attack group, possible values are: deny, alert, not used
    waf_attack_group_action_wpv       = optional(string, "deny")     # Action for Policy Violations attack group, possible values are: deny, alert, not used
    waf_attack_group_action_wpra      = optional(string, "deny")     # Action for Protocol attack group, possible values are: deny, alert, not used
    waf_penalty_box_enable            = optional(bool, true)         # Enable WAF Penalty Box
    waf_penalty_box_action            = optional(string, "deny")     # Action for WAF Penalty Box, possible values are: deny, alert, not used
    api_constraints_enable            = optional(bool, false)        # Enable API Constraints
    reputation_protection_enable      = optional(bool, true)         # Enable Reputation Protection
    reputation_profile_default        = optional(list(string), [])   # List of default reputation profiles to include
    reputation_profile_default_action = optional(string, "alert")    # Action for default reputation profiles, possible values are: alert, deny
    reputation_profile = optional(list(object({                      # List of custom reputation profiles to include
      name               = optional(string)                          # Name of the reputation profile
      action             = optional(string)                          # Action for the reputation profile, possible values are: alert, deny
      context            = optional(string)                          #  Context for the reputation profile, possible values are: WEBATCK, DOSATCK, WEBSCRP, SCANTL
      shared_ip_handling = optional(string)                          # Shared IP handling for the reputation profile, possible values are: NON_SHARED, SHARED_ONLY, BOTH
      threshold          = optional(string)                          # Threshold for the reputation profile
    })), [])
    client_forward_to_http_header                = optional(bool, false) # Enable Client IP forwarding to HTTP header
    client_forward_shared_ip_to_http_header_siem = optional(bool, false) # Enable Client IP forwarding for shared IPs to HTTP header for SIEM
    bot_management_settings = object({                                   # Bot Management settings
      enable_bot_management                   = optional(bool, true)     # Enable Bot Management
      add_akamai_bot_header                   = optional(bool, false)    # Add Akamai Bot header to requests
      third_party_proxy_service_in_use        = optional(bool, true)     # Indicate if a third-party proxy service is in use
      remove_bot_management_cookies           = optional(bool, true)     # Remove Bot Management cookies from responses
      enable_active_detections                = optional(bool, true)     # Enable active detections for Bot Management
      enable_browser_validation               = optional(bool, true)     # Enable browser validation for Bot Management
      include_transactional_endpoint_requests = optional(bool, false)    # Include transactional endpoint requests in Bot Management
      include_transactional_endpoint_status   = optional(bool, false)    # Add Akamai Bot header to requests to all transactional endpoints
    })
    custom_bot_path = optional(string, "json_files/custom_bots") # Path to custom bot definitions
    custom_bot_category = optional(list(object({                 # List of custom bot categories
      category_name = optional(string)                           # Name of the custom bot category
      action        = optional(string)                           # Action for the custom bot category, possible values are: monitor, tarpit, slow, deny
      bots          = optional(list(string))                     # List of bots in the custom bot category
    })), [])
    bot_category_action = object({                                           # Akamai Bot category actions, possible values are: monitor, tarpit, slow, deny, delay, skip
      academic_or_research_bots                = optional(string, "monitor") # Action for Academic or Research bots
      artificial_intelligence_ai_bots          = optional(string, "monitor") # Action for Artificial Intelligence (AI) bots
      automated_shopping_cart_and_sniper_bots  = optional(string, "monitor") # Action for Automated Shopping Cart and Sniper bots
      business_intelligence_bots               = optional(string, "monitor") # Action for Business Intelligence bots
      ecommerce_search_engine_bots             = optional(string, "monitor") # Action for Ecommerce Search Engine bots
      enterprise_data_aggregator_bots          = optional(string, "monitor") # Action for Enterprise Data Aggregator bots
      financial_account_aggregator_bots        = optional(string, "monitor") # Action for Financial Account Aggregator bots
      financial_services_bots                  = optional(string, "monitor") # Action for Financial Services bots
      job_search_engine_bots                   = optional(string, "monitor") # Action for Job Search Engine bots
      media_or_entertainment_search_bots       = optional(string, "monitor") # Action for Media or Entertainment Search bots
      news_aggregator_bots                     = optional(string, "monitor") # Action for News Aggregator bots
      online_advertising_bots                  = optional(string, "monitor") # Action for Online Advertising bots
      rss_feed_reader_bots                     = optional(string, "monitor") # Action for RSS Feed Reader bots
      seo_analytics_or_marketing_bots          = optional(string, "monitor") # Action for SEO Analytics or Marketing bots
      site_monitoring_and_web_development_bots = optional(string, "monitor") # Action for Site Monitoring and Web Development bots
      social_media_or_blog_bots                = optional(string, "monitor") # Action for Social Media or Blog bots
      web_archiver_bots                        = optional(string, "monitor") # Action for Web Archiver bots
      web_search_engine_bots                   = optional(string, "monitor") # Action for Web Search Engine bots
    })
    bot_detection_action = object({                                         # Akamai Bot transparent detection actions, possible values are: monitor, tarpit, slow, deny, delay, skip
      impersonators_of_known_bots             = optional(string, "tarpit")  # Action for Impersonators of Known bots
      development_frameworks                  = optional(string, "monitor") # Action for Development Frameworks
      http_libraries                          = optional(string, "monitor") # Action for HTTP Libraries
      web_services_libraries                  = optional(string, "tarpit")  # Action for Web Services Libraries
      open_source_crawlers_scraping_platforms = optional(string, "tarpit")  # Action for Open Source Crawlers and Scraping Platforms
      headless_browsers_automation_tools      = optional(string, "monitor") # Action for Headless Browsers and Automation Tools
      declared_bots                           = optional(string, "monitor") # Action for Declared bots
      aggressive_web_crawlers                 = optional(string, "monitor") # Action for Aggressive Web Crawlers
      browser_impersonator                    = optional(string, "monitor") # Action for Browser Impersonators
      webscraper_reputation_action            = optional(string, "slow")    # Action for Webscraper Reputation
      webscraper_reputation_sensitivity       = optional(number, 4)         # Sensitivity for Webscraper Reputation, possible values are: 1 (most sensitive) to 10 (least sensitive)
      cookie_integrity_failed                 = optional(string, "tarpit")  # Action for Cookie Integrity Failed
      session_validation_action               = optional(string, "monitor") # Action for Session Validation
      session_validation_sensitivity          = optional(string, "MEDIUM")  # Sensitivity for Session Validation, possible values are: LOW, MEDIUM, HIGH
      client_disabled_javascript              = optional(string, "tarpit")  # Action for Client Disabled Javascript
      javascript_fingerprint_anomaly          = optional(string, "monitor") # Action for Javascript Fingerprint Anomaly
      javascript_fingerprint_not_received     = optional(string, "monitor") # Action for Javascript Fingerprint Not Received
    })
    inject_javascript = optional(string, "AROUND_PROTECTED_OPERATIONS") # JavaScript injection timing, possible values are: AROUND_PROTECTED_OPERATIONS, NEVER, ALWAYS
  })
  default = {
    match_target = {
      default = {
        type = "website"
        website = {
          default_file = "NO_MATCH"
        }
      }
    }
    override_evasive_path = false
    override_request_body = false
    http_logging = {
      override = false
    }
    attack_payload_logging = {
      override = "false"
    }
    pragma_header = {
      override = "false"
    }
    ip_geo_protection_enable                     = true
    ip_geo_mode                                  = "allow"
    ukraine_geo_control_action                   = "none"
    dos_rate_protection_enable                   = true
    dos_slowpost_protection_enable               = true
    dos_slow_rate_action                         = "abort"
    dos_slow_rate_threshold_rate                 = 10
    dos_slow_rate_threshold_period               = 60
    waf_protection_enable                        = true
    waf_mode                                     = "ASE_AUTO"
    waf_attack_group_action_cmdi                 = "deny"
    waf_attack_group_action_xss                  = "deny"
    waf_attack_group_action_lfi                  = "deny"
    waf_attack_group_action_rfi                  = "deny"
    waf_attack_group_action_sql                  = "deny"
    waf_attack_group_action_to                   = "deny"
    waf_attack_group_action_wat                  = "deny"
    waf_attack_group_action_wpla                 = "deny"
    waf_attack_group_action_wpv                  = "deny"
    waf_attack_group_action_wpra                 = "deny"
    waf_penalty_box_enable                       = true
    waf_penalty_box_action                       = "deny"
    api_constraints_enable                       = false
    reputation_protection_enable                 = true
    reputation_profile_default_action            = "alert"
    client_forward_to_http_header                = false
    client_forward_shared_ip_to_http_header_siem = false
    bot_management_settings = {
      enable_bot_management                   = true
      add_akamai_bot_header                   = false
      third_party_proxy_service_in_use        = true
      remove_bot_management_cookies           = true
      enable_active_detections                = true
      enable_browser_validation               = true
      include_transactional_endpoint_requests = false
      include_transactional_endpoint_status   = false
    }
    custom_bot_path = "json_files/custom_bots"
    bot_category_action = {
      academic_or_research_bots                = "monitor"
      artificial_intelligence_ai_bots          = "monitor"
      automated_shopping_cart_and_sniper_bots  = "monitor"
      business_intelligence_bots               = "monitor"
      ecommerce_search_engine_bots             = "monitor"
      enterprise_data_aggregator_bots          = "monitor"
      financial_account_aggregator_bots        = "monitor"
      financial_services_bots                  = "monitor"
      job_search_engine_bots                   = "monitor"
      media_or_entertainment_search_bots       = "monitor"
      news_aggregator_bots                     = "monitor"
      online_advertising_bots                  = "monitor"
      rss_feed_reader_bots                     = "monitor"
      seo_analytics_or_marketing_bots          = "monitor"
      site_monitoring_and_web_development_bots = "monitor"
      social_media_or_blog_bots                = "monitor"
      web_archiver_bots                        = "monitor"
      web_search_engine_bots                   = "monitor"
    }
    bot_detection_action = {
      impersonators_of_known_bots             = "tarpit"
      development_frameworks                  = "monitor"
      http_libraries                          = "monitor"
      web_services_libraries                  = "tarpit"
      open_source_crawlers_scraping_platforms = "tarpit"
      headless_browsers_automation_tools      = "monitor"
      declared_bots                           = "monitor"
      aggressive_web_crawlers                 = "monitor"
      browser_impersonator                    = "monitor"
      webscraper_reputation_action            = "slow"
      webscraper_reputation_sensitivity       = 4
      cookie_integrity_failed                 = "tarpit"
      session_validation_action               = "monitor"
      session_validation_sensitivity          = "MEDIUM"
      client_disabled_javascript              = "tarpit"
      javascript_fingerprint_anomaly          = "monitor"
      javascript_fingerprint_not_received     = "monitor"
    }
    inject_javascript = "AROUND_PROTECTED_OPERATIONS"
  }
  nullable = false
}
