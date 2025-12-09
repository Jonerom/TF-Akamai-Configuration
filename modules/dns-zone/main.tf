resource "akamai_dns_zone" "primary" {
  count                    = lower(var.type) == "primary" ? 1 : 0
  contract                 = var.contract
  group                    = var.group
  zone                     = var.zone
  end_customer_id          = try(var.end_customer_id, null)
  comment                  = var.comment
  type                     = lower(var.type)
  sign_and_serve           = var.sns
  sign_and_serve_algorithm = try(var.sns_algorithm, null)
  dynamic "outbound_zone_transfer" {
    for_each = var.outbound_zone_transfer != null ? [var.outbound_zone_transfer] : []
    content {
      enabled        = outbound_zone_transfer.value.enabled
      acl            = outbound_zone_transfer.value.acl
      notify_targets = outbound_zone_transfer.value.notify_targets
      dynamic "tsig_key" {
        for_each = lookup(outbound_zone_transfer.value, "tsig_key", null) != null ? [outbound_zone_transfer.value.tsig_key] : []
        content {
          name      = tsig_key.value.name
          algorithm = tsig_key.value.algorithm
          secret    = tsig_key.value.secret
        }
      }
    }
  }
}

resource "akamai_dns_zone" "secondary" {
  count                    = lower(var.type) == "secondary" ? 1 : 0
  contract                 = var.contract
  group                    = var.group
  zone                     = var.zone
  end_customer_id          = try(var.end_customer_id, null)
  comment                  = var.comment
  type                     = lower(var.type)
  masters                  = var.masters
  sign_and_serve           = var.sns
  sign_and_serve_algorithm = try(var.sns_algorithm, null)
  dynamic "tsig_key" {
    for_each = var.tsig_key != null ? [var.tsig_key] : []
    content {
      name      = tsig_key.value.name
      algorithm = tsig_key.value.algorithm
      secret    = tsig_key.value.secret
    }
  }
  dynamic "outbound_zone_transfer" {
    for_each = var.outbound_zone_transfer != null ? [var.outbound_zone_transfer] : []
    content {
      enabled        = outbound_zone_transfer.value.enabled
      acl            = outbound_zone_transfer.value.acl
      notify_targets = outbound_zone_transfer.value.notify_targets
      dynamic "tsig_key" {
        for_each = lookup(outbound_zone_transfer.value, "tsig_key", null) != null ? [outbound_zone_transfer.value.tsig_key] : []
        content {
          name      = tsig_key.value.name
          algorithm = tsig_key.value.algorithm
          secret    = tsig_key.value.secret
        }
      }
    }
  }
}

resource "akamai_dns_zone" "alias" {
  count           = lower(var.type) == "alias" ? 1 : 0
  contract        = var.contract
  group           = var.group
  zone            = var.zone
  end_customer_id = try(var.end_customer_id, null)
  comment         = var.comment
  type            = lower(var.type)
  target          = try(var.target, null)
}
