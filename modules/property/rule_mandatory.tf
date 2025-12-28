// Default rule
locals {
  all_jsons = concat(
    ["${data.akamai_property_rules_builder.mandatory.json}"],
    local.basic_json_rules,
    local.additional_json_rules,
    local.waf_json_rules,
  )
  basic_json_rules      = var.basic_json_rules ? local.basic_json_rule_values : []
  additional_json_rules = var.additional_json_rules != null && length(try(var.additional_json_rules, [])) > 0 ? var.additional_json_rules : []
  waf_json_rules        = local.waf_json_rules_values != null && length(try(local.waf_json_rules_values, [])) > 0 ? local.waf_json_rules_values : []
}
resource "random_string" "origin_prefix" {
  length  = 4
  special = false
  upper   = false
  lower   = true
  numeric = true
}

## Default Rule ##
data "akamai_property_rules_builder" "default_rule" {
  rules_v2025_10_16 {
    name      = "default"
    is_secure = try(var.edge_hostname_type == lower("enhanced") ? true : false, false)
    comments  = var.default_json_rule_values.comments
    behavior {
      origin {
        origin_type                   = var.default_json_rule_values.origin_type
        hostname                      = var.default_json_rule_values.origin_type == "CUSTOMER" ? var.default_json_rule_values.forward_host_header != "" ? var.default_json_rule_values.forward_host_header : "${random_string.origin_prefix}.${var.name}.${var.host_configuration[0].zone}" : null
        forward_host_header           = var.default_json_rule_values.origin_type == "CUSTOMER" ? var.default_json_rule_values.forward_host_header : null
        custom_forward_host_header    = var.default_json_rule_values.origin_type == "CUSTOMER" && var.default_json_rule_values.forward_host_header == "CUSTOM" ? var.default_json_rule_values.custom_forward_host_header : null
        cache_key_hostname            = var.default_json_rule_values.origin_type == "CUSTOMER" ? var.default_json_rule_values.cache_key_hostname : null
        ip_version                    = var.default_json_rule_values.origin_type == "CUSTOMER" ? var.default_json_rule_values.ip_version : null
        compress                      = var.default_json_rule_values.origin_type == "CUSTOMER" ? var.default_json_rule_values.compress : null
        enable_true_client_ip         = var.default_json_rule_values.origin_type == "CUSTOMER" ? var.default_json_rule_values.enable_true_client_ip : null
        true_client_ip_header         = var.default_json_rule_values.origin_type == "CUSTOMER" && var.default_json_rule_values.enable_true_client_ip ? var.default_json_rule_values.true_client_ip_header : null
        true_client_ip_client_setting = var.default_json_rule_values.origin_type == "CUSTOMER" && var.default_json_rule_values.enable_true_client_ip ? var.default_json_rule_values.true_client_ip_client_setting : null
        http_port                     = var.default_json_rule_values.origin_type == "CUSTOMER" ? var.default_json_rule_values.http_port : null
        https_port                    = var.default_json_rule_values.origin_type == "CUSTOMER" ? var.default_json_rule_values.https_port : null
        min_tls_version               = var.default_json_rule_values.origin_type == "CUSTOMER" ? var.default_json_rule_values.min_tls_version : null
        origin_sni                    = var.default_json_rule_values.origin_type == "CUSTOMER" ? var.default_json_rule_values.origin_sni : null
        verification_mode             = var.default_json_rule_values.origin_type == "CUSTOMER" ? var.default_json_rule_values.verification_mode : null
        custom_valid_cn_values        = var.default_json_rule_values.origin_type == "CUSTOMER" && var.default_json_rule_values.verification_mode == "CUSTOM" ? var.default_json_rule_values.custom_valid_cn_values : null
        origin_certs_to_honor         = var.default_json_rule_values.origin_type == "CUSTOMER" && var.default_json_rule_values.verification_mode == "CUSTOM" ? var.default_json_rule_values.origin_certs_to_honor : null
        ## The following fields are commented out as they pertain to AKAMAI_OBJECT_STORAGE and NET_STORAGE origin types, which are not currently supported by the .
        # origin_host                   = var.default_json_rule_values.origin_type == "AKAMAI_OBJECT_STORAGE" || var.default_json_rule_values.origin_type == "NET_STORAGE" ? var.default_json_rule_values.origin_host : null
        # container_name                = var.default_json_rule_values.origin_type == "AKAMAI_OBJECT_STORAGE" ? var.default_json_rule_values.container_name : null
        # account_id                    = var.default_json_rule_values.origin_type == "NET_STORAGE" ? var.default_json_rule_values.account_id : null
        # use_sps                       = var.default_json_rule_values.origin_type == "NET_STORAGE" ? var.default_json_rule_values.use_sps : null
        # sps_key_name                  = var.default_json_rule_values.origin_type == "NET_STORAGE" && var.default_json_rule_values.use_sps ? var.default_json_rule_values.sps_key_name : null
      }
    }
    children = local.all_jsons
  }
}

## Mandatory Rules ##
locals {
  mandatory_jsons = var.site_shield_name != null && var.site_shield_name != "" ? concat(
    ["${data.akamai_property_rules_builder.cp_code.json}"],
    ["${data.akamai_property_rules_builder.caching.json}"],
    [try("${data.akamai_property_rules_builder.site_shield.json}"), null]
    ) : concat(
    ["${data.akamai_property_rules_builder.cp_code.json}"],
    ["${data.akamai_property_rules_builder.caching.json}"]
  )
}

data "akamai_property_rules_builder" "mandatory" {
  rules_v2025_10_16 {
    name                  = "Global configurations"
    children              = local.mandatory_jsons
    criteria_must_satisfy = "all"
  }
}

data "akamai_property_rules_builder" "cp_code" {
  rules_v2025_10_16 {
    name = "CP Code Assignment"
    behavior {
      cp_code {
        value {
          id   = var.cp_code_id
          name = "cpCode"
        }
      }
    }
    criteria_must_satisfy = "all"
  }
}

data "akamai_property_rules_builder" "caching" {
  rules_v2025_10_16 {
    name = "Caching"
    behavior {
      caching {
        behavior              = var.default_json_rule_values.caching_behavior
        must_revalidate       = (var.default_json_rule_values.caching_behavior != "NO_STORE" && var.default_json_rule_values.caching_behavior != "BYPASS_CACHE") ? lookup(var.default_json_rule_values.must_revalidate, null) : null
        ttl                   = (var.default_json_rule_values.caching_behavior != "NO_STORE" && var.default_json_rule_values.caching_behavior != "BYPASS_CACHE") ? lookup(var.default_json_rule_values.ttl, null) : null
        enhanced_rfc_support  = (var.default_json_rule_values.caching_behavior == "CACHE_CONTROL" || var.default_json_rule_values.caching_behavior == "CACHE_CONTROL_AND_EXPIRES") ? lookup(var.default_json_rule_values.enhanced_rfc_support, null) : null
        honor_private         = (var.default_json_rule_values.caching_behavior == "CACHE_CONTROL" || var.default_json_rule_values.caching_behavior == "CACHE_CONTROL_AND_EXPIRES") ? lookup(var.default_json_rule_values.honor_private, null) : null
        honor_must_revalidate = (var.default_json_rule_values.caching_behavior == "CACHE_CONTROL" || var.default_json_rule_values.caching_behavior == "CACHE_CONTROL_AND_EXPIRES") ? lookup(var.default_json_rule_values.honor_must_revalidate, null) : null
      }
    }
    criteria_must_satisfy = "all"
  }
}

data "akamai_property_rules_builder" "site_shield" {
  rules_v2025_10_16 {
    name = "Site Shield"
    behavior {
      site_shield {
        ssmap {
          name = var.site_shield_name != null && var.site_shield_name != "" ? var.site_shield_name : ""
        }
      }
    }
    criteria_must_satisfy = "all"
  }
}

