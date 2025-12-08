
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

# Generate the map for properties which don't have Content Provider custom codes created
locals {
  new_cp_property_config = try(var.akamai_map.property_configuration, {})
  properties_without_custom_cp_name = {
    for prop_key, prop_value in local.new_cp_property_config :
    prop_key => prop_value
    if try(prop_value.custom_cp_name, null) == null
  }
}
module "zone_cp_code" {
  for_each   = try(local.new_cp_property_config, {})
  source     = "./modules/cp-code"
  contract   = data.akamai_contract.my_contract.id
  group      = data.akamai_group.my_group.id
  name       = each.value.property_name
  product_id = each.value.product_id
  timeout    = try(each.value.timeout, null)
}

# Generate the map for the certificate and edge hostname to be created if the certificate_name is set
locals {
  new_certificate_config = try(var.akamai_map.property_configuration, {})
  certificate_map = {
    for prop_key, prop_value in local.new_certificate_config :
    prop_key => prop_value
    if try(prop_value.certificate_name, null) != null
  }
}
module "certificate" {
  for_each                              = try(local.certificate_map, {})
  source                                = "./modules/certificate-dv"
  contract                              = data.akamai_contract.my_contract.id
  name                                  = each.value.certificate_name
  zone_sans_map                         = each.value.dns_configuration
  acknowledge_pre_verification_warnings = try(each.value.certificate_acknowledge_pre_verification_warnings, null)
  secure_network                        = try(each.value.certificate_secure_network, null)
  sni_only                              = try(each.value.certificate_sni_only, null)
  signature_algorithm                   = try(each.value.certificate_signature_algorithm, null)
  allow_duplicate_common_name           = try(each.value.certificate_allow_duplicate_common_name, null)
  certificate_chain_type                = try(each.value.certificate_chain_type, null)
  timeout_certificate_creation          = try(each.value.timeout_certificate_creation, null)
  timeout_certificate_validation        = try(each.value.timeout_certificate_validation, null)
  network_configuration                 = try(each.value.network_configuration, null)
  csr                                   = try(var.organization_details.csr, null)
  organization                          = var.organization_details.organization
  admin_contact                         = var.organization_details.admin_contact
  tech_contact                          = var.organization_details.tech_contact
}

module "edge_hostname" {
  for_each            = try(local.certificate_map, {})
  source              = "./modules/edge-hostname"
  contract            = data.akamai_contract.my_contract.id
  group               = data.akamai_group.my_group.id
  product_id          = each.value.product_id
  hostname            = "${each.value.property_name}-${try(each.value.edge_hostname_affix, null)}"
  edge_hostname_type  = try(each.value.edge_hostname_type, null)
  ip_behavior         = try(each.value.ip_behavior, null)
  ttl                 = try(each.value.edge_hostname_ttl, null)
  status_update_email = try(each.value.edge_hostname_status_update_email, null)
  use_cases           = try(each.value.edge_hostname_use_cases, null)
  certificate_id      = module.certificate[each.key].id
  timeout             = try(each.value.edge_hostname_timeout, null)
}



module "property" {
  for_each         = var.akamai_map.property_configuration
  source           = "./modules/property-waf"
  contract         = data.akamai_contract.my_contract.id
  group            = data.akamai_group.my_group.id
  name             = each.value.property_name
  product_id       = each.value.product_id
  cp_code_id       = try(module.custom_cp_code[each.value.cp_code_name].id, module.zone_cp_code[each.key].id)
  site_shield_name = try(each.value.site_shield_name, null)
}

/*
validate that the cp code product_id matches property product_id in case it's not new



create property


create shield dns records
create dns records




create web security
assign hosts into web Security

create site shield
assign properties into site shield

*/
