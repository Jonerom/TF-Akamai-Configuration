# Flatten the map of zone SANs into a list of SANs for the certificate enrollment
locals {
  zone_sans = try(var.zone_sans_map, {})
  flat_san_list = flatten([
    for zone_key, zone_config in local.zone_sans :
    [
      for record_index, record in zone_config.records :
      "${record.name}.${zone_config.zone}"
    ]
  ])
}

resource "akamai_cps_dv_enrollment" "certificate" {
  contract_id                           = var.contract
  acknowledge_pre_verification_warnings = var.acknowledge_pre_verification_warnings
  common_name                           = var.name
  sans                                  = var.sans != "" ? var.sans : local.flat_san_list
  secure_network                        = var.secure_network
  sni_only                              = var.sni_only
  allow_duplicate_common_name           = var.allow_duplicate_common_name
  timeouts {
    default = try(var.timeout_certificate_creation, null)
  }
  admin_contact {
    first_name       = var.admin_contact.first_name
    last_name        = var.admin_contact.last_name
    phone            = var.admin_contact.phone
    email            = var.admin_contact.email
    country_code     = try(var.admin_contact.country_code, var.organization.country_code)
    region           = try(var.admin_contact.region, var.organization.region)
    city             = try(var.admin_contact.city, var.organization.city)
    address_line_one = try(var.admin_contact.address_line_one, var.organization.address_line_one)
    address_line_two = try(var.admin_contact.address_line_two, try(var.organization.address_line_two, null))
    postal_code      = try(var.admin_contact.postal_code, var.organization.postal_code)
  }
  tech_contact {
    first_name       = var.tech_contact.first_name
    last_name        = var.tech_contact.last_name
    phone            = var.tech_contact.phone
    email            = var.tech_contact.email
    country_code     = try(var.tech_contact.country_code, var.organization.country_code)
    region           = try(var.tech_contact.region, var.organization.region)
    city             = try(var.tech_contact.city, var.organization.city)
    address_line_one = try(var.tech_contact.address_line_one, var.organization.address_line_one)
    address_line_two = try(var.tech_contact.address_line_two, try(var.organization.address_line_two, null))
    postal_code      = try(var.tech_contact.postal_code, var.organization.postal_code)
  }
  certificate_chain_type = var.certificate_chain_type
  csr {
    preferred_trust_chain = try(var.csr.preferred_trust_chain, null)
    country_code          = var.csr.country_code != null ? var.csr.country_code : var.organization.country_code
    state                 = try(var.csr.state, null)
    city                  = var.csr.city != null ? var.csr.city : var.organization.city
    organization          = var.csr.organization != null ? var.csr.organization : var.organization.name
    organizational_unit   = try(var.csr.organizational_unit, null)
  }
  network_configuration {
    disallowed_tls_versions = var.network_configuration.disallowed_tls_versions
    clone_dns_names         = var.network_configuration.clone_dns_names
    geography               = var.network_configuration.geography
    ocsp_stapling           = var.network_configuration.ocsp_stapling
    preferred_ciphers       = var.network_configuration.preferred_ciphers
    must_have_ciphers       = var.network_configuration.must_have_ciphers
    quic_enabled            = var.network_configuration.quic_enabled
  }
  signature_algorithm = var.signature_algorithm
  organization {
    name             = var.organization.name
    phone            = var.organization.phone
    country_code     = var.organization.country_code
    region           = var.organization.region
    city             = var.organization.city
    address_line_one = var.organization.address_line_one
    address_line_two = try(var.organization.address_line_two, null)
    postal_code      = var.organization.postal_code
  }
}

# Flatten the map of DNS challenges and the certificate enrollment using temp data to satisfy plan-time requirements
locals {
  dns_challenges_map = {
    for san in akamai_cps_dv_enrollment.certificate.dns_challenges : san.domain => san
  }
  flattened_dns_records = merge([
    for zone_key, zone_config in local.zone_sans :
    {
      for record_index, record in zone_config.records :
      "${zone_config.zone}-${record_index}" => {
        zone = zone_config.zone
        san  = "${record.name}.${zone_config.zone}"
      }
    }
  ]...)
  dns_challenge_map_simple = var.zone != "" ? {
    for key, record_info in local.flattened_dns_records :
    key => {
      challenge_data = lookup(local.dns_challenges_map, record_info.san, { full_path = "TBD", response_body = "TBD" })
    }
  } : {}

  dns_challenge_map_complex = var.zone == "" ? {
    for key, record_info in local.flattened_dns_records :
    key => {
      challenge_data = lookup(local.dns_challenges_map, record_info.san, { full_path = "TBD", response_body = "TBD" })
      zone           = record_info.zone
    }
  } : {}
}
module "cert_txt_validation_complex" {
  for_each    = local.dns_challenge_map_complex
  source      = "../dns-records"
  zone        = each.value.zone
  record      = each.value.challenge_data.full_path
  type        = "TXT"
  ttl         = 60
  target_list = ["${each.value.challenge_data.response_body}"]
}
module "cert_txt_validation_simple" {
  for_each    = local.dns_challenge_map_simple
  source      = "../dns-records"
  zone        = var.zone
  record      = each.value.challenge_data.full_path
  type        = "TXT"
  ttl         = 60
  target_list = ["${each.value.challenge_data.response_body}"]
}

resource "time_sleep" "cert_txt_wait" {
  depends_on = [
    module.cert_txt_validation_simple,
    module.cert_txt_validation_complex,
  ]
  create_duration = "300s"
}

locals {
  san_list = distinct(concat(var.sans, [var.name]))
}
resource "akamai_cps_dv_validation" "cert-validation" {
  depends_on    = [time_sleep.cert_txt_wait]
  enrollment_id = akamai_cps_dv_enrollment.certificate.id
  sans          = local.san_list
  timeouts {
    default = try(var.timeout_certificate_validation, null)
  }
}
