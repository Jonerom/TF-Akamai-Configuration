### Create the policy
resource "random_string" "policy_prefix" {
  length  = 4
  special = false
  upper   = true
  numeric = true
}

resource "akamai_appsec_security_policy" "security_policy" {
  config_id                      = var.config_id
  security_policy_name           = var.policy_name
  security_policy_prefix         = var.policy_prefix != null ? var.policy_prefix : random_string.policy_prefix.result
  default_settings               = try(var.default_settings, null)
  create_from_security_policy_id = try(var.create_from_security_policy_id, null)
}

##################
### SECURITY POLICY DETAILS
##################
### Establish to what hosts the policy applies (Security Policy Details -> Website / API Match Target)
resource "akamai_appsec_match_target" "match_target" {
  for_each  = var.security_policy.match_target
  config_id = var.config_id
  match_target = length(try(each.value.website)) > 0 ? templatefile("${path.module}/json_templates/match_target_website.json", {
    type               = "website",
    config_id          = var.config_id,
    default_file       = each.value.website.default_file,
    hostname_list      = each.value.website.hostname_list,
    security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
    }) : length(try(each.value.apis)) > 0 ? templatefile("${path.module}/json_templates/match_target_api.json", {
    type               = "api",
    config_id          = var.config_id,
    api_id             = each.value.apis.api_id,
    api_name           = each.value.apis.api_name,
    security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  }) : templatefile("${path.module}/json_templates/match_target_basic.json")
}
### Override and establish Evasive URL Request Matching (Security Policy Details -> Advanced Settings -> Inspection)
resource "akamai_appsec_advanced_settings_evasive_path_match" "evasive_path" {
  count              = var.security_policy.override_evasive_path ? 1 : 0
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  enable_path_match  = var.security_policy.evasive_path_match_enable
}
### Override and establish Request size inspection limit (Security Policy Details -> Advanced Settings -> Inspection)
resource "akamai_appsec_advanced_settings_request_body" "request_body" {
  count                                  = var.security_policy.override_request_body ? 1 : 0
  config_id                              = var.config_id
  security_policy_id                     = akamai_appsec_security_policy.security_policy.security_policy_id
  request_body_inspection_limit          = var.security_policy.request_body_inspection_limit
  request_body_inspection_limit_override = var.security_policy.override_request_body
}
### Override and establish HTTP header logging (Security Policy Details -> Advanced Settings -> Logging)
resource "akamai_appsec_advanced_settings_logging" "http_logging" {
  count              = var.security_policy.http_logging.override ? 1 : 0
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  logging = templatefile("${path.module}/json_templates/http_logging.json", {
    override      = var.security_policy.http_logging.override,
    enabled       = var.security_policy.http_logging.enabled,
    cookies       = var.security_policy.http_logging.cookies,
    custom_type   = var.security_policy.http_logging.custom_type,
    standard_type = var.security_policy.http_logging.standard_type,
  })
}
### Override and establish Attack payload logging (Security Policy Details -> Advanced Settings -> Logging)
resource "akamai_appsec_advanced_settings_attack_payload_logging" "attack_payload_logging" {
  count              = var.security_policy.attack_payload_logging.override ? 1 : 0
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_payload_logging = templatefile("${path.module}/json_templates/attack_payload_logging.json", {
    override      = var.security_policy.attack_payload_logging.override,
    enabled       = var.security_policy.attack_payload_logging.enabled,
    request_body  = var.security_policy.attack_payload_logging.request_body,
    response_body = var.security_policy.attack_payload_logging.response_body
  })
}
## Override and establish Strip Pragma Debug Headers (Security Policy Details -> Advanced Settings -> Platform Security)
resource "akamai_appsec_advanced_settings_pragma_header" "pragma_header" {
  count              = var.security_policy.pragma_header.override ? 1 : 0
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  pragma_header = templatefile("${path.module}/json_templates/pragma_header.json", {
    action                 = var.security_policy.pragma_header.action,
    conditional_operator   = var.security_policy.pragma_header.conditional_operator,
    exclude_condition_list = var.security_policy.pragma_header.exclude_condition_list
  })
}

##################
### IP/GEO FIREWALL
##################
### Enable Geo Protection (IP/Geo Firewall)
resource "akamai_appsec_ip_geo_protection" "protection" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  enabled            = var.security_policy.ip_geo_protection_enable
}
### Configure Geo Protection (IP/Geo Firewall)
resource "akamai_appsec_ip_geo" "ip_geo_settings" {
  count              = var.security_policy.ip_geo_protection_enable ? 1 : 0
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  mode               = var.security_policy.ip_geo_mode
  dynamic "asn_controls" {
    for_each = try(var.security_policy.asn_network_control, [])
    content {
      asn_network_lists = asn_controls.value
      action            = asn_controls.action
    }
  }
  dynamic "geo_controls" {
    for_each = try(var.security_policy.geo_network_control, [])
    content {
      geo_network_lists = geo_controls.value
      action            = geo_controls.action
    }
  }
  dynamic "ip_controls" {
    for_each = try(var.security_policy.ip_network_control, [])
    content {
      ip_network_lists = ip_controls.value
      action           = ip_controls.action
    }
  }
  exception_ip_network_lists = try(var.security_policy.exception_ip_network_lists, [])
  ukraine_geo_control_action = var.security_policy.ukraine_geo_control_action
}

##################
### DOS PROTECTION
##################
### Enable DoS Protection - Rate Limiting Policies (DoS Protection -> Rate Limiting Policies)
resource "akamai_appsec_rate_protection" "protection" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  enabled            = var.security_policy.dos_rate_protection_enable
}
### Configure DoS Protection Rate Limiting Policies (DoS Protection -> Rate Limiting Policies)
resource "akamai_appsec_rate_policy_action" "appsec_rate_policy_action" {
  for_each           = toset(var.security_policy.dos_rate_policy.rate_policy_file_list)
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  rate_policy_id     = akamai_appsec_rate_policy.appsec_rate_policy[each.key].rate_policy_id
  ipv4_action        = var.security_policy.dos_rate_policy.ipv4_action
  ipv6_action        = var.security_policy.dos_rate_policy.ipv6_action
}
### Defines DoS Protection Rate Limiting Policies (DoS Protection -> Rate Limiting Policies [shared])
resource "akamai_appsec_rate_policy" "appsec_rate_policy" {
  for_each    = toset(var.security_policy.dos_rate_policy.rate_policy_file_list)
  config_id   = var.config_id
  rate_policy = file("${var.security_policy.dos_rate_policy.file_path}/${each.key}.json")
}
### Enable DoS Protection - Slow Post Protection (DoS Protection -> Slow Post Protection)
resource "akamai_appsec_slowpost_protection" "protection" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  enabled            = var.security_policy.dos_slowpost_protection_enable
}
### Configure DoS Protection - Slow Post Protection (DoS Protection -> Slow Post Protection)
resource "akamai_appsec_slow_post" "slow_post" {
  config_id                  = var.config_id
  security_policy_id         = akamai_appsec_security_policy.security_policy.security_policy_id
  slow_rate_action           = var.security_policy.dos_slow_rate_action
  slow_rate_threshold_rate   = var.security_policy.dos_slow_rate_threshold_rate
  slow_rate_threshold_period = var.security_policy.dos_slow_rate_threshold_period
  duration_threshold_timeout = var.security_policy.dos_duration_threshold_timeout
}
##################
### CUSTOM RULES
##################
### Establish Custom Rule (Custom Rule)
# resource "akamai_appsec_custom_rule" "custom_rule" {
#   config_id   = var.config_id
#   custom_rule = akamai_appsec_custom_rule_action.create_custom_rule_action.id
# }
### Configure Custom Rule (Custom Rule)
# resource "akamai_appsec_custom_rule_action" "create_custom_rule_action" {
#   config_id          = var.config_id
#   security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
#   custom_rule_id     = akamai_appsec_custom_rule.custom_rule.id
#   custom_rule_action = var.security_policy.custom_action
# }
##################
### WEB APPLICATION FIREWALL
##################
### Enable WAF protection (Web Application Firewall)
resource "akamai_appsec_waf_protection" "protection" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  enabled            = var.security_policy.waf_protection_enable
}
### Configure WAF protection mode (Web Application Firewall -> Rapid Rules)
resource "akamai_appsec_waf_mode" "waf_mode" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  mode               = var.security_policy.waf_mode
}
### Configure WAF Attack protections (Web Application Firewall -> Protections by Attack Group)
resource "akamai_appsec_attack_group" "attack_group_cmdi" {
  config_id           = var.config_id
  security_policy_id  = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group        = "CMD"
  attack_group_action = var.security_policy.waf_attack_group_action_cmdi
}
### Configure WAF Attack protections (Web Application Firewall -> Protections by Attack Group)
resource "akamai_appsec_attack_group" "attack_group_xss" {
  config_id           = var.config_id
  security_policy_id  = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group        = "XSS"
  attack_group_action = var.security_policy.waf_attack_group_action_xss
}
### Configure WAF Attack protections (Web Application Firewall -> Protections by Attack Group)
resource "akamai_appsec_attack_group" "attack_group_lfi" {
  config_id           = var.config_id
  security_policy_id  = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group        = "LFI"
  attack_group_action = var.security_policy.waf_attack_group_action_lfi
}
### Configure WAF Attack protections (Web Application Firewall -> Protections by Attack Group)
resource "akamai_appsec_attack_group" "attack_group_rfi" {
  config_id           = var.config_id
  security_policy_id  = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group        = "RFI"
  attack_group_action = var.security_policy.waf_attack_group_action_rfi
}
### Configure WAF Attack protections (Web Application Firewall -> Protections by Attack Group)
resource "akamai_appsec_attack_group" "attack_group_sql" {
  config_id           = var.config_id
  security_policy_id  = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group        = "SQL"
  attack_group_action = var.security_policy.waf_attack_group_action_sql
}
### Configure WAF Attack protections (Web Application Firewall -> Protections by Attack Group)
resource "akamai_appsec_attack_group" "attack_group_to" {
  config_id           = var.config_id
  security_policy_id  = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group        = "OUTBOUND"
  attack_group_action = var.security_policy.waf_attack_group_action_to
}
### Configure WAF Attack protections (Web Application Firewall -> Protections by Attack Group)
resource "akamai_appsec_attack_group" "attack_group_wat" {
  config_id           = var.config_id
  security_policy_id  = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group        = "WAT"
  attack_group_action = var.security_policy.waf_attack_group_action_wat
}
### Configure WAF Attack protections (Web Application Firewall -> Protections by Attack Group)
resource "akamai_appsec_attack_group" "attack_group_wpla" {
  config_id           = var.config_id
  security_policy_id  = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group        = "PLATFORM"
  attack_group_action = var.security_policy.waf_attack_group_action_wpla
}
### Configure WAF Attack protections (Web Application Firewall -> Protections by Attack Group)
resource "akamai_appsec_attack_group" "attack_group_wpv" {
  config_id           = var.config_id
  security_policy_id  = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group        = "POLICY"
  attack_group_action = var.security_policy.waf_attack_group_action_wpv
}
### Configure WAF Attack protections (Web Application Firewall -> Protections by Attack Group)
resource "akamai_appsec_attack_group" "attack_group_wpra" {
  config_id           = var.config_id
  security_policy_id  = akamai_appsec_security_policy.security_policy.security_policy_id
  attack_group        = "PROTOCOL"
  attack_group_action = var.security_policy.waf_attack_group_action_wpra
}
### Configure WAF penalty box (Web Application Firewall -> Penalty Box)
resource "akamai_appsec_penalty_box" "penalty_box" {
  config_id              = var.config_id
  security_policy_id     = akamai_appsec_security_policy.security_policy.security_policy_id
  penalty_box_protection = var.security_policy.waf_penalty_box_enable
  penalty_box_action     = var.security_policy.waf_penalty_box_action
}
### Configure WAF penalty box conditions (Web Application Firewall -> Penalty Box -> Conditions)
# resource "akamai_appsec_penalty_box_conditions" "my_conditions" {
#   config_id              = var.config_id
#   security_policy_id     = akamai_appsec_security_policy.security_policy.security_policy_id
#   penalty_box_conditions = file("$path.root/conditions.json")
# }

##################
### API REQUEST CONSTRAINTS
##################
### Enable API Constraints Protection (API Request Constraints)
resource "akamai_appsec_api_constraints_protection" "protection" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  enabled            = var.security_policy.api_constraints_enable
}
### Configure API Request constraints (API Request Constraints -> Registered APIs Covered by Match Target)
# resource "akamai_appsec_api_request_constraints" "api_request_constraints" {
#   config_id          = var.config_id
#   security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
#   api_endpoint_id    = data.akamai_appsec_api_endpoints.api_endpoint.id
#   action             = var.security_policy.api_constraint.action
# }

##################
### CLIENT REPUTATION
##################
### Enable Client Reputation Protection (Client Reputation)
resource "akamai_appsec_reputation_protection" "protection" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  enabled            = var.security_policy.reputation_protection_enable
}
### Configure default client reputation profiles (Client Reputation -> Profiles)
resource "akamai_appsec_reputation_profile_action" "default_reputation_profile_action" {
  for_each              = toset(var.security_policy.reputation_profile_default)
  config_id             = var.config_id
  security_policy_id    = akamai_appsec_security_policy.security_policy.security_policy_id
  reputation_profile_id = each.key
  action                = var.security_policy.reputation_profile_default_action
}
### Configure client reputation profiles (Client Reputation -> Profiles)
resource "akamai_appsec_reputation_profile_action" "appsec_reputation_profile_action" {
  for_each              = { for profile in var.security_policy.reputation_profile : profile.name => profile }
  config_id             = var.config_id
  security_policy_id    = akamai_appsec_security_policy.security_policy.security_policy_id
  reputation_profile_id = akamai_appsec_reputation_profile.reputation_profile[each.key].reputation_profile_id
  action                = each.value.action
}
### Defines client reputation profiles (Client Reputation -> Profiles [shared])
resource "akamai_appsec_reputation_profile" "reputation_profile" {
  for_each  = { for profile in var.security_policy.reputation_profile : profile.name => profile }
  config_id = var.config_id
  reputation_profile = templatefile("${path.module}/json_templates/reputation_profile.json", {
    name               = each.value.name,
    context            = each.value.context,
    shared_ip_handling = each.value.shared_ip_handling,
    threshold          = each.value.threshold
  })
}
### Configure client reputation profile analysis (Client Reputation -> Reputation Analysis)
resource "akamai_appsec_reputation_profile_analysis" "reputation_analysis" {
  config_id                             = var.config_id
  security_policy_id                    = akamai_appsec_security_policy.security_policy.security_policy_id
  forward_to_http_header                = var.security_policy.client_forward_to_http_header
  forward_shared_ip_to_http_header_siem = var.security_policy.client_forward_shared_ip_to_http_header_siem
}

##################
### BOT MANAGEMENT
##################
### Enable and configure the Bot Management flags (Bot management) + (general bot management -> general settings) + (general bot management -> active detections)
resource "akamai_botman_bot_management_settings" "bot_management_settings" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  bot_management_settings = templatefile("${path.module}/json_templates/bot_management.json", {
    enable_bot_management                   = var.security_policy.bot_management_settings.enable_bot_management,
    add_akamai_bot_header                   = var.security_policy.bot_management_settings.add_akamai_bot_header,
    third_party_proxy_service_in_use        = var.security_policy.bot_management_settings.third_party_proxy_service_in_use,
    remove_bot_management_cookies           = var.security_policy.bot_management_settings.remove_bot_management_cookies,
    enable_active_detections                = var.security_policy.bot_management_settings.enable_active_detections,
    enable_browser_validation               = var.security_policy.bot_management_settings.enable_browser_validation,
    include_transactional_endpoint_requests = var.security_policy.bot_management_settings.include_transactional_endpoint_requests
    include_transactional_endpoint_status   = var.security_policy.bot_management_settings.include_transactional_endpoint_status
  })
}
### Configure Custom Bot Categories (bot management -> general bot management -> custom bot categories -> Category)
resource "akamai_botman_custom_bot_category" "custom_bot_category" {
  for_each  = { for category in var.security_policy.custom_bot_category : category.category_name => category }
  config_id = var.config_id
  custom_bot_category = templatefile("${path.module}/json_templates/bot_category_simple.json", {
    category_name = each.value.category_name
  })
}
# Fetch Custom Bot ID list and nested bots for related resources
data "akamai_botman_custom_bot_category" "custom_categories" {
  depends_on = [akamai_botman_custom_bot_category.custom_bot_category]
  config_id  = var.config_id
}
locals {
  custom_categories_decoded = jsondecode(data.akamai_botman_custom_bot_category.custom_categories.json)
  custom_bot_list = flatten([
    for category in var.security_policy.custom_bot_category : [
      for bot in coalesce(category.bots, []) : {
        category_name = category.category_name
        bot           = bot
      }
    ]
  ])
}
### Define Custom Bot Category Sequene (bot management -> general bot management -> custom bot categories)
# resource "akamai_botman_custom_bot_category_sequence" "custom_category_sequence" {
#   config_id    = var.config_id
#   category_ids = ["cc9c3f89-e179-4892-89cf-d5e623ba9dc7", "d79285df-e399-43e8-bb0f-c0d980a88e4f", "afa309b8-4fd5-430e-a061-1c61df1d2ac2"]
# }
### Set Custom Bot Action (bot management -> general bot management -> custom bot categories -> Action)
resource "akamai_botman_custom_bot_category_action" "custom_category_action" {
  for_each           = { for category in var.security_policy.custom_bot_category : category.category_name => category }
  depends_on         = [akamai_botman_custom_bot_category.custom_bot_category]
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id = join("", [
    for cat in local.custom_categories_decoded["categories"] : cat["categoryId"]
    if cat["categoryName"] == each.value.category_name
  ])
  custom_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = each.value.action
  })
  # Category_id changes ignored due to resource bug
  lifecycle {
    ignore_changes = [
      category_id
    ]
  }
}
### Define Custom Bot Sequences per Category (bot management -> general bot management -> custom bot categories -> bot)
# resource "akamai_botman_custom_bot_category_item_sequence" "custom_category_item_sequence" {
#  for_each           = { for category in var.security_policy.custom_bot_category : category.category_name => category }
#   config_id          = var.config_id
#   category_id  = join("", [
#    for cat in local.custom_categories_decoded["categories"] : cat["categoryId"]
#    if cat["categoryName"] == each.value.category_name
#  ])
#   bot_ids 	 = ["1a2bcd3e-8i9j-6g7h-4d5f-0k1l2m3n4o5p", "647efc82-123a-45b6-78c9-1a2bcd3e4a8z", "1x2y3zd4-a1b2-c3d4-87b4-bf7623550472"]
# }
### Create Custom Bots per Category (bot management -> general bot management -> custom bot categories -> bots)
resource "akamai_botman_custom_defined_bot" "custom_defined_bot" {
  for_each   = { for bot in local.custom_bot_list : bot.bot => bot }
  depends_on = [akamai_botman_custom_bot_category.custom_bot_category]
  config_id  = var.config_id
  custom_defined_bot = templatefile("${var.security_policy.custom_bot_path}/${each.value.bot}.json", {
    category_id = join("", [
      for cat in local.custom_categories_decoded["categories"] : cat["categoryId"]
      if cat["categoryName"] == each.value.category_name
    ])
  })
}
### Establish Akamai Bot Category Actions(bot management -> general bot management ->  akamai bot categories -> actions)
# Academic or Research Bots
resource "akamai_botman_akamai_bot_category_action" "academic_or_research_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "0c508e1d-73a4-4366-9e48-3c4a080f1c5d"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.academic_or_research_bots
  })
}
#  Artificial Intelligence (AI) Bots
resource "akamai_botman_akamai_bot_category_action" "artificial_intelligence_ai_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "352fca87-71ee-4b8d-ae15-d36772556072"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.artificial_intelligence_ai_bots
  })
}
# Automated Shopping Cart and Sniper Bots
resource "akamai_botman_akamai_bot_category_action" "automated_shopping_cart_and_sniper_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "75493431-b41a-492c-8324-f12158783ce1"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.automated_shopping_cart_and_sniper_bots
  })
}
# Business Intelligence Bots
resource "akamai_botman_akamai_bot_category_action" "business_intelligence_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "8a70d29c-a491-4583-9768-7deea2f379c1"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.business_intelligence_bots
  })
}
# E-Commerce Search Engine Bots
resource "akamai_botman_akamai_bot_category_action" "ecommerce_search_engine_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "47bcfb70-f3f5-458b-8f7c-1773b14bc6a4"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.ecommerce_search_engine_bots
  })
}
# Enterprise Data Aggregator Bots
resource "akamai_botman_akamai_bot_category_action" "enterprise_data_aggregator_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "50395ad2-2673-41a4-b317-9b70742fd40f"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.enterprise_data_aggregator_bots
  })
}
# Financial Account Aggregator Bots
resource "akamai_botman_akamai_bot_category_action" "financial_account_aggregator_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "c6692e03-d3a8-49b0-9566-5003eeaddbc1"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.financial_account_aggregator_bots
  })
}
# Financial Services Bots
resource "akamai_botman_akamai_bot_category_action" "financial_services_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "53598904-21f5-46b1-8b51-1b991beef73b"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.financial_services_bots
  })
}
# Job Search Engine Bots
resource "akamai_botman_akamai_bot_category_action" "job_search_engine_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "2f169206-f32c-48f7-b281-d534cf1ceeb3"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.job_search_engine_bots
  })
}
# Media or Entertainment Search Bots
resource "akamai_botman_akamai_bot_category_action" "media_or_entertainment_search_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "dff258d5-b1ad-4bbb-b1d1-cf8e700e5bba"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.media_or_entertainment_search_bots
  })
}
# News Aggregator Bots
resource "akamai_botman_akamai_bot_category_action" "news_aggregator_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "ade03247-6519-4591-8458-9b7347004b63"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.news_aggregator_bots
  })
}
# Online Advertising Bots
resource "akamai_botman_akamai_bot_category_action" "online_advertising_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "36b27e0c-76fc-44a4-b913-c598c5af8bba"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.online_advertising_bots
  })
}
# RSS Feed Reader Bots
resource "akamai_botman_akamai_bot_category_action" "rss_feed_reader_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "b58c9929-9fd0-45f7-86f4-1d6259285c3c"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.rss_feed_reader_bots
  })
}
# SEO, Analytics or Marketing Bots
resource "akamai_botman_akamai_bot_category_action" "seo_analytics_or_marketing_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "f7558c03-9033-46ce-bbda-10eeda62a5d4"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.seo_analytics_or_marketing_bots
  })
}
# Site Monitoring and Web Development Bots
resource "akamai_botman_akamai_bot_category_action" "site_monitoring_and_web_development_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "07782c03-8d21-4491-9078-b83514e6508f"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.site_monitoring_and_web_development_bots
  })
}
# Social Media or Blog Bots
resource "akamai_botman_akamai_bot_category_action" "social_media_or_blog_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "7035af8d-148c-429a-89da-de41e68c72d8"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.social_media_or_blog_bots
  })
}
# Web Archiver Bots
resource "akamai_botman_akamai_bot_category_action" "web_archiver_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "831ef84a-c2bb-4b0d-b90d-bcd16793b830"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.web_archiver_bots
  })
}
# Web Search Engine Bots
resource "akamai_botman_akamai_bot_category_action" "web_search_engine_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  category_id        = "4e14219f-6568-4c9d-9bd8-b29ca2afc422"
  akamai_bot_category_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_category_action.web_search_engine_bots
  })
}
### Establish Transparent Bot Detections Actions (bot management -> general bot management ->  transpartent detections -> actions)
# Impersonators of Known Bots
resource "akamai_botman_bot_detection_action" "impersonators_of_known_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "fda1ffb9-ef46-4570-929c-7449c0c750f8"
  bot_detection_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_detection_action.impersonators_of_known_bots
  })
}
# Development Frameworks
resource "akamai_botman_bot_detection_action" "development_frameworks" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "da005ad3-8bbb-43c8-a783-d97d1fb71ad2"
  bot_detection_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_detection_action.development_frameworks
  })
}
# HTTP Libraries
resource "akamai_botman_bot_detection_action" "http_libraries" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "578dad32-024b-48b4-930c-db81831686f4"
  bot_detection_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_detection_action.http_libraries
  })
}
# Web Services Libraries
resource "akamai_botman_bot_detection_action" "web_services_libraries" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "872ed6c2-514c-4055-9c44-9782b1c783bf"
  bot_detection_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_detection_action.web_services_libraries
  })
}
# Open Source Crawlers/Scraping Platforms
resource "akamai_botman_bot_detection_action" "open_source_crawlers_scraping_platforms" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "601192ae-f5e2-4a29-8f75-a0bcd3584c2b"
  bot_detection_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_detection_action.open_source_crawlers_scraping_platforms
  })
}
# Headless Browsers/Automation Tools
resource "akamai_botman_bot_detection_action" "headless_browsers_automation_tools" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "b88cba13-4d11-46fe-a7e0-b47e78892dc4"
  bot_detection_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_detection_action.headless_browsers_automation_tools
  })
}
# Declared Bots (Keyword Match)
resource "akamai_botman_bot_detection_action" "action_declared_bots" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "074df68e-fb28-432a-ac6d-7cfb958425f1"
  bot_detection_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_detection_action.declared_bots
  })
}
# Aggressive Web Crawlers
resource "akamai_botman_bot_detection_action" "aggressive_web_crawlers" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "5bc041ad-c840-4202-9c2e-d7fc873dbeaf"
  bot_detection_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_detection_action.aggressive_web_crawlers
  })
}
# Browser Impersonator 
resource "akamai_botman_bot_detection_action" "browser_impersonator" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "a3b92f75-fa5d-436e-b066-426fc2919968"
  bot_detection_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_detection_action.browser_impersonator
  })
}
# Web Scraper Reputation
resource "akamai_botman_bot_detection_action" "webscraper_reputation" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "9712ab32-83bb-43ab-a46d-4c2a5a42e7e2"
  bot_detection_action = templatefile("${path.module}/json_templates/bot_detection_action_webscraper_reputation.json", {
    action      = var.security_policy.bot_detection_action.webscraper_reputation_action
    sensitivity = var.security_policy.bot_detection_action.webscraper_reputation_sensitivity
  })
}
### Establish Active Bot Detections Actions (bot management -> general bot management ->  active detections -> actions)
# Cookie Integrity Failed
resource "akamai_botman_bot_detection_action" "cookie_integrity_failed" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "4f1fd3ea-7072-4cd0-8d12-24f275e6c75d"
  bot_detection_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_detection_action.cookie_integrity_failed
  })
}
# Session Validation
resource "akamai_botman_bot_detection_action" "session_validation" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "1bb748e2-b3ad-41db-85fa-c69e62be59dc"
  bot_detection_action = templatefile("${path.module}/json_templates/bot_detection_action_session_activity.json", {
    action      = var.security_policy.bot_detection_action.session_validation_action
    sensitivity = var.security_policy.bot_detection_action.session_validation_sensitivity
  })
}
# Client Disabled JavaScript (Noscript Triggered)
resource "akamai_botman_bot_detection_action" "client_disabled_javascript" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "c5623efa-f326-41d1-9601-a2d201bedf63"
  bot_detection_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_detection_action.client_disabled_javascript
  })
}
# JavaScript Fingerprint Anomaly
resource "akamai_botman_bot_detection_action" "javascript_fingerprint_anomaly" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "393cba3d-656f-48f1-abe4-8dd5028c6871"
  bot_detection_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_detection_action.javascript_fingerprint_anomaly
  })
}
# JavaScript Fingerprint Not Received
resource "akamai_botman_bot_detection_action" "javascript_fingerprint_not_received" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  detection_id       = "c7f70f75-e3e2-4181-8ef8-30afb6576147"
  bot_detection_action = templatefile("${path.module}/json_templates/action_simple.json", {
    action = var.security_policy.bot_detection_action.javascript_fingerprint_not_received
  })
}
### Configure JavaScript Injections (bot management -> transactional endpoint protection -> JavaScript Injection Settings)
resource "akamai_botman_javascript_injection" "javascript_injection" {
  config_id          = var.config_id
  security_policy_id = akamai_appsec_security_policy.security_policy.security_policy_id
  javascript_injection = templatefile("${path.module}/json_templates/javascript_injection_simple.json", {
    inject_javascript = var.security_policy.inject_javascript
  })
}
### Create JavaScript Injection rules (bot management -> transactional endpoint protection -> JavaScript Injection Settings -> Rule)
# resource "akamai_botman_content_protection_javascript_injection_rule" "my_javascript_injection_rule" {
#   config_id                                       = var.config_id
#   security_policy_id                              = akamai_appsec_security_policy.security_policy.security_policy_id
#   content_protection_javascript_injection_rule    = file("${path.module}/my_javascript_injection_rule.json")
# }
### Define Protected Rules Sequence (bot management -> transactional endpoint protection -> Protected  Operations)
# resource "akamai_botman_content_protection_rule_sequence" "my_content_protection_rule_sequence" {
#   config_id                                       = var.config_id
#   security_policy_id                              = akamai_appsec_security_policy.security_policy.security_policy_id
#   content_protection_rule_ids = ["1234abcd-5678-efgh-901i-jk23l45mn67o", "9876abcd-5432-efgh-109i-jk87l65mn43o"]
# }
### Define Protected Rules (bot management -> transactional endpoint protection -> Protected  Operations)
# resource "akamai_botman_content_protection_rule" "my_content_protection_rule" {
#   config_id                                       = var.config_id
#   security_policy_id                              = akamai_appsec_security_policy.security_policy.security_policy_id
#   content_protection_rule = file("${path.module}/content-protection-rule.json")
# }
### Define Bot Category Exceptions (bot management -> transactional endpoint protection -> exceptions)
# Fetch Bot Category IDs
# locals {
#   custom_bot_exception_category_list = [ for exception in var.security_policy.custom_bot_exception_category_list : akamai_botman_custom_bot_category.custom_bot_category[exception].id]
# }
# Set Bot Category Exceptions
# resource "akamai_botman_bot_category_exception" "bot_category_exception" {
#   config_id                                       = var.config_id
#   security_policy_id                              = akamai_appsec_security_policy.security_policy.security_policy_id
#   bot_category_exception = templatefile("${path.module}/json_templates/transactional_endpoint_custom_bot_exception.json", {
#     inject_javascript = local.custom_bot_exception_category_list
#   })
# }
##################
### CLIENT-SIDE PROTECTION & COMPLIANCE
##################

### Client Side Security Settings (Client-side protection & compliance -> )
# resource "akamai_botman_client_side_security" "client_side_security" {
#   config_id            = var.config_id
#   client_side_security = file("${path.module}/client_side_security.json")
# }
