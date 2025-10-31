locals {
  akamaitlc_target_list = formatlist("A %s", var.target_list)
}

resource "akamai_dns_record" "a" {
  count      = upper(var.type) == "A" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  target     = var.target_list
}

resource "akamai_dns_record" "akamaicdn" {
  count      = upper(var.type) == "AKAMAICDN" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = 20
  target     = var.target_list
}

## Added for reference only, see readme.md
resource "akamai_dns_record" "akamaitlc" {
  count      = upper(var.type) == "AKAMAITLC" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = 20
  target     = local.akamaitlc_target_list
}

resource "akamai_dns_record" "cname" {
  count      = upper(var.type) == "CNAME" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  target     = var.target_list
}

resource "akamai_dns_record" "txt" {
  count      = upper(var.type) == "TXT" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  target     = var.target_list
}

resource "akamai_dns_record" "mx" {
  count      = upper(var.type) == "MX" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  target     = var.target_list
  priority   = var.priority
}
