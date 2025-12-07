resource "akamai_cps_dv_enrollment" "certificate" {
  contract_id                           = var.contract
  acknowledge_pre_verification_warnings = var.acknowledge_pre_verification_warnings
  common_name                           = var.name
  sans                                  = var.sans
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
    country_code          = try(var.csr.country_code, var.organization.country_code)
    state                 = try(var.csr.state, null)
    city                  = try(var.csr.city, var.organization.city)
    organization          = try(var.csr.organization, var.organization.name)
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

resource "akamai_dns_record" "cert-txt-validation" {
  for_each   = { for san in akamai_cps_dv_enrollment.certificate.dns_challenges : san.domain => san }
  zone       = var.zone
  name       = each.value.full_path
  recordtype = "TXT"
  ttl        = 60
  target     = ["${each.value.response_body}"]
}

resource "time_sleep" "cert-txt-wait" {
  depends_on      = [akamai_dns_record.cert-txt-validation]
  create_duration = "300s"
}

locals {
  san_list = distinct(concat(var.sans, [var.name]))
}
resource "akamai_cps_dv_validation" "cert-validation" {
  depends_on    = [time_sleep.cert-txt-wait]
  enrollment_id = akamai_cps_dv_enrollment.certificate.id
  sans          = local.san_list
  timeouts {
    default = try(var.timeout_certificate_validation, null)
  }
}
