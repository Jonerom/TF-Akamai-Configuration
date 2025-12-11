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

resource "akamai_dns_record" "aaaa" {
  count      = upper(var.type) == "AAAA" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  target     = var.target_list
}

resource "akamai_dns_record" "afsdb" {
  count      = upper(var.type) == "AFSDB" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  target     = var.target_list
  subtype    = try(var.subtype, null)
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

resource "akamai_dns_record" "caa" {
  count      = upper(var.type) == "CAA" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  target     = var.target_list
}

resource "akamai_dns_record" "cert" {
  count         = upper(var.type) == "CERT" ? 1 : 0
  zone          = var.zone
  name          = var.record
  recordtype    = upper(var.type)
  ttl           = var.ttl
  type_value    = var.type_value
  type_mnemonic = var.type_mnemonic
  keytag        = var.keytag
  algorithm     = var.algorithm
  certificate   = var.certificate
}

resource "akamai_dns_record" "cname" {
  count      = upper(var.type) == "CNAME" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  target     = var.target_list
}

resource "akamai_dns_record" "dnskey" {
  count      = upper(var.type) == "DNSKEY" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  flags      = var.flags
  protocol   = var.protocol
  algorithm  = var.algorithm
  key        = var.key
}

resource "akamai_dns_record" "cdnskey" {
  count      = upper(var.type) == "CDNSKEY" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  flags      = var.flags
  protocol   = var.protocol
  algorithm  = var.algorithm
  key        = var.key
}

resource "akamai_dns_record" "ds" {
  count       = upper(var.type) == "DS" ? 1 : 0
  zone        = var.zone
  name        = var.record
  recordtype  = upper(var.type)
  ttl         = var.ttl
  keytag      = var.keytag
  algorithm   = var.algorithm
  digest_type = var.digest_type
  digest      = var.digest
}

resource "akamai_dns_record" "cds" {
  count       = upper(var.type) == "CDS" ? 1 : 0
  zone        = var.zone
  name        = var.record
  recordtype  = upper(var.type)
  ttl         = var.ttl
  keytag      = var.keytag
  algorithm   = var.algorithm
  digest_type = var.digest_type
  digest      = var.digest
}

resource "akamai_dns_record" "hinfo" {
  count      = upper(var.type) == "HINFO" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  hardware   = var.hardware
  software   = var.software
}

resource "akamai_dns_record" "https" {
  count        = upper(var.type) == "https" ? 1 : 0
  zone         = var.zone
  name         = var.record
  recordtype   = upper(var.type)
  ttl          = var.ttl
  svc_priority = var.svc_priority
  svc_params   = var.svc_params
  target_name  = var.target_name
}

resource "akamai_dns_record" "loc" {
  count      = upper(var.type) == "LOC" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  target     = var.target_list
}

resource "akamai_dns_record" "mx" {
  count              = upper(var.type) == "MX" ? 1 : 0
  zone               = var.zone
  name               = var.record
  recordtype         = upper(var.type)
  ttl                = var.ttl
  target             = var.target_list
  priority           = try(var.priority, null)
  priority_increment = try(var.priority_increment, null)
}

resource "akamai_dns_record" "naptr" {
  count       = upper(var.type) == "NAPTR" ? 1 : 0
  zone        = var.zone
  name        = var.record
  recordtype  = upper(var.type)
  ttl         = var.ttl
  target      = var.target_list
  order       = var.order
  preference  = var.preference
  flagsnaptr  = var.flagsnaptr
  service     = var.service
  regexp      = var.regexp
  replacement = var.replacement
}

resource "akamai_dns_record" "ns" {
  count      = upper(var.type) == "NS" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = 86400
  target     = var.target_list
}

resource "akamai_dns_record" "nsec3" {
  count                  = upper(var.type) == "NSEC3" ? 1 : 0
  zone                   = var.zone
  name                   = var.record
  recordtype             = upper(var.type)
  ttl                    = var.ttl
  algorithm              = var.algorithm
  flags                  = var.flags
  iterations             = var.iterations
  salt                   = var.salt
  next_hashed_owner_name = var.next_hashed_owner_name
  type_bitmaps           = var.type_bitmaps
}

resource "akamai_dns_record" "nsec3param" {
  count      = upper(var.type) == "NSEC3PARAM" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  algorithm  = var.algorithm
  flags      = var.flags
  iterations = var.iterations
  salt       = var.salt
}

resource "akamai_dns_record" "ptr" {
  count      = upper(var.type) == "PTR" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  target     = var.target_list
}

resource "akamai_dns_record" "rp" {
  count      = upper(var.type) == "RP" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  mailbox    = var.mailbox
  txt        = var.txt
}

resource "akamai_dns_record" "rpsig" {
  count        = upper(var.type) == "RPSIG" ? 1 : 0
  zone         = var.zone
  name         = var.record
  recordtype   = upper(var.type)
  ttl          = var.ttl
  type_covered = var.type_covered
  algorithm    = var.algorithm
  original_ttl = var.original_ttl
  expiration   = var.expiration
  inception    = var.inception
  keytag       = var.keytag
  signer       = var.signer
  signature    = var.signature
  labels       = var.labels
}

resource "akamai_dns_record" "soa" {
  count         = upper(var.type) == "SOA" ? 1 : 0
  zone          = var.zone
  name          = var.record
  recordtype    = upper(var.type)
  ttl           = 64800
  name_server   = var.name_server
  email_address = var.email_address
  serial        = var.serial
  refresh       = var.refresh
  retry         = var.retry
  expiry        = var.expiry
  nxdomain_ttl  = var.nxdomain_ttl
}

resource "akamai_dns_record" "spf" {
  count      = upper(var.type) == "SPF" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  target     = var.target_list
}

resource "akamai_dns_record" "srv" {
  count      = upper(var.type) == "SRV" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  target     = var.target_list
  priority   = var.priority
  weight     = var.weight
  port       = var.port
}

resource "akamai_dns_record" "sshfp" {
  count            = upper(var.type) == "SSHFP" ? 1 : 0
  zone             = var.zone
  name             = var.record
  recordtype       = upper(var.type)
  ttl              = var.ttl
  algorithm        = var.algorithm
  fingerprint_type = var.fingerprint_type
  fingerprint      = var.fingerprint
}

resource "akamai_dns_record" "svcb" {
  count        = upper(var.type) == "SVCB" ? 1 : 0
  zone         = var.zone
  name         = var.record
  recordtype   = upper(var.type)
  ttl          = var.ttl
  target_name  = var.target_name
  svc_priority = var.svc_priority
  svc_params   = var.svc_params
}


resource "akamai_dns_record" "tlsa" {
  count       = upper(var.type) == "TLSA" ? 1 : 0
  zone        = var.zone
  name        = var.record
  recordtype  = upper(var.type)
  ttl         = var.ttl
  usage       = var.usage
  selector    = var.selector
  match_type  = var.match_type
  certificate = var.certificate
}


resource "akamai_dns_record" "txt" {
  count      = upper(var.type) == "TXT" ? 1 : 0
  zone       = var.zone
  name       = var.record
  recordtype = upper(var.type)
  ttl        = var.ttl
  target     = var.target_list
}
