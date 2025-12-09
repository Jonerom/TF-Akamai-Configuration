locals {
  flattened_waf_dns_records = var.edge_hostname != null ? (
    merge([
      for zone_key, zone_config in var.host_configuration :
      {
        for record_index, record in zone_config.records :
        "${zone_config.zone}-${record_index}" => {
          zone   = zone_config.zone
          name   = record.name
          config = record
        }
      }
    ]...)
  ) : {}
  flattened_dns_records = merge([
    for zone_key, zone_config in var.host_configuration :
    {
      for record_index, record in zone_config.records :
      "${zone_config.zone}-${record_index}" => {
        zone   = zone_config.zone
        name   = record.name
        config = record
      }
    }
  ])
  final_rule = length(try(var.custom_json_rules, "")) > 0 ? var.custom_json_rules : data.akamai_property_rules_builder.default_rule.json

}

resource "random_string" "shield_prefix" {
  for_each = try(local.flattened_waf_dns_records, {})
  length   = 6
  special  = false
  upper    = false
  lower    = true
  numeric  = true
}

resource "akamai_property" "property" {
  name          = "var.name"
  product_id    = var.product_id
  contract_id   = var.contract
  group_id      = var.group
  version_notes = try(var.version_notes, null)
  rule_format   = var.rule_format
  rules         = local.final_rule
  dynamic "hostnames" {
    for_each = local.flattened_waf_dns_records
    content {
      cname_from             = hostnames.value.name != "" ? "${hostnames.value.name}.${hostnames.value.zone}" : hostnames.value.zone
      cname_to               = var.edge_hostname
      cert_provisioning_type = hostnames.value.config.cert_provisioning_type
      dynamic "ccm_certificates" {
        for_each = hostnames.value.config.ccm_certificates != null ? hostnames.value.config.ccm_certificates : []
        content {
          ecdsa_cert_id = ccm_certificates.value.type == "ecdsa" ? ccm_certificates.value.id : null
          rsa_cert_id   = ccm_certificates.value.type == "rsa" ? ccm_certificates.value.id : null
        }
      }
    }
  }
}

resource "akamai_property_activation" "staging_activation" {
  depends_on                     = [akamai_property.property]
  property_id                    = akamai_property.property.id
  network                        = "STAGING"
  contact                        = var.support_team_emails
  note                           = try(var.activation_note, "${var.name} terraform automated activation in staging")
  version                        = akamai_property.property.latest_version
  auto_acknowledge_rule_warnings = try(var.auto_acknowledge_rule_warnings_staging, null)
  timeouts {
    default = try(var.timeout_staging_activation, null)
  }
}

resource "akamai_property_activation" "prod_activation" {
  depends_on                     = [akamai_property_activation.staging_activation]
  property_id                    = akamai_property.property.id
  network                        = "PRODUCTION"
  contact                        = var.support_team_emails
  note                           = try(var.activation_note, "${var.name} terraform automated activation in production")
  version                        = akamai_property.property.latest_version
  auto_acknowledge_rule_warnings = try(var.auto_acknowledge_rule_warnings_production, null)
  timeouts {
    default = try(var.timeout_production_activation, null)
  }
}

module "shield_records" {
  for_each    = try(local.flattened_waf_dns_records, {})
  source      = "./modules/dns-records"
  zone        = each.value.zone
  record      = "${random_string.shield_prefix[each.key].result}-${each.value.name}.${each.value.zone}"
  type        = "A"
  target_list = each.value.config.records.targets
  ttl         = try(each.value.config.ttl, null)
}

module "waf_records" {
  for_each    = try(local.flattened_waf_dns_records, {})
  source      = "./modules/dns-records"
  zone        = each.value.zone
  record      = each.value.name != "" ? "${each.value.name}.${each.value.zone}" : each.value.zone
  type        = each.value.name != "" ? "CNAME" : "AKAMAICDN"
  target_list = ["${random_string.shield_prefix[each.key].result}-${each.value.name}.${each.value.zone}"]
  ttl         = try(each.value.config.ttl, null)
}

module "records" {
  for_each    = try(local.flattened_dns_records, {})
  source      = "./modules/dns-records"
  zone        = each.value.zone
  record      = each.value.name != "" ? "${each.value.name}.${each.value.zone}" : each.value.zone
  type        = each.value.name != "" ? each.value.type : "AKAMAICDN"
  target_list = each.value.targets
  ttl         = try(each.value.ttl, null)
}
