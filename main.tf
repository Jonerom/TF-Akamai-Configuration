
module "zone" {
  for_each               = var.akamai_map.zone_configuration
  source                 = "./modules/dns-zone"
  contract               = data.akamai_contract.my_contract.id
  group                  = data.akamai_group.my_group.id
  zone                   = each.value.zone_name
  type                   = each.value.type
  sns                    = each.value.sns
  sns_algorithm          = each.value.sns_algorithm
  outbound_zone_transfer = each.value.outbound_zone_transfer
  masters                = each.value.masters
  tsig_key               = each.value.tsig_key
  target                 = each.value.target
}

# Generate the map for DNS Records not linked to properties including the zone name
locals {
  non_property_zones = try(var.akamai_map.non_property_dns_configuration, {})
  flattened_dns_records = merge([
    for zone_key, zone_config in local.non_property_zones :
    {
      for record_index, record in zone_config.records :
      "${zone_config.zone}-${record_index}" => {
        zone        = zone_config.zone
        record_name = record.name
        type        = record.type
        targets     = record.targets
        ttl         = try(record.ttl, null)
        priority    = try(record.priority, null)
      }
    }
  ])
}
module "non_property_dns_records" {
  for_each    = local.flattened_dns_records
  source      = "./modules/dns-records"
  zone        = each.value.zone
  record      = each.value.record_name
  type        = each.value.type
  target_list = each.value.targets
  ttl         = each.value.ttl
  priority    = each.value.priority
}

module "custom_cp_code" {
  for_each   = try(var.akamai_map.custom_content_provider_configuration, {})
  source     = "./modules/cp-code"
  contract   = data.akamai_contract.my_contract.id
  group      = data.akamai_group.my_group.id
  name       = each.value.cp_name
  product_id = each.value.product_id
  timeout    = try(each.value.timeout, null)
}

module "property" {
  for_each           = var.akamai_map.property_configuration
  source             = "./modules/property-waf"
  contract           = data.akamai_contract.my_contract.id
  group              = data.akamai_group.my_group.id
  name               = each.value.property_name
  product_id         = each.value.product_id
  cp_code_name       = try(module.custom_cp_code[each.value.cp_code_name].id, each.value.cp_code_name)
  create_new_cp_code = length(try(module.custom_cp_code[each.value.cp_code_name], null)) > 0
  site_shield_name   = try(each.value.site_shield_name, null)
}
