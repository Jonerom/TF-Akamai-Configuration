locals {
  waf_json_rules_values = [for key in local.flattened_waf_dns_records : data.akamai_property_rules_builder.custom_origins[key].json]
}

data "akamai_property_rules_builder" "custom_origins" {
  for_each = local.flattened_waf_dns_records
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "origins for ${each.key}"
      behavior {
        origin {
          origin_type                   = var.default_json_rule_values.origin_type
          hostname                      = var.default_json_rule_values.origin_type == "CUSTOMER" ? var.default_json_rule_values.forward_host_header != "" ? var.default_json_rule_values.forward_host_header : "${random_string.shield_prefix[each.key].result}-${each.value.name}.${each.value.zone}" : null
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
        }
      }
      criterion {
        hostname {
          match_operator = "IS_ONE_OF"
          values = [
            each.key
          ]
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
