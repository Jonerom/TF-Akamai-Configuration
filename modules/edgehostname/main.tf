locals {
  use_cases_list = coalesce(var.use_cases, [])
  formatted_use_cases = [
    for uc in local.use_cases_list : {
      option  = uc.option
      type    = uc.type
      useCase = uc.use_case
    }
  ]
  use_cases_json_string = jsonencode({
    useCases = local.formatted_use_cases
  })
}

resource "random_string" "edge_hostname_suffix" {
  length  = 6
  special = false
  upper   = false
  lower   = true
  numeric = true
}

resource "akamai_edge_hostname" "edge-hostname" {
  product_id  = var.product_id
  contract_id = var.contract
  group_id    = var.group
  edge_hostname = (
    var.edge_hostname_type == lower("enhanced")
    ? "${var.hostname}-${random_string.edge_hostname_suffix.result}.edgekey.net" :
    var.edge_hostname_type == lower("standard")
    ? "${var.hostname}-${random_string.edge_hostname_suffix.result}.edgesuite.net" :
    var.edge_hostname_type == lower("shared")
    ? "${var.hostname}-${random_string.edge_hostname_suffix.result}.akamaized.net" :
    "${var.hostname}-${random_string.edge_hostname_suffix.result}.edgesuite.net"
  )
  ip_behavior         = var.ip_behavior
  ttl                 = try(var.ttl, null)
  status_update_email = try(var.status_update_email, null)
  use_cases           = try(local.use_cases_json_string, null)
  certificate = (
    var.edge_hostname_type == lower("enhanced")
    ? var.certificate_enrollment_id :
    try(var.certificate_enrollment_id, null)
  )
  timeouts {
    default = try(var.timeout, null)
  }
}

