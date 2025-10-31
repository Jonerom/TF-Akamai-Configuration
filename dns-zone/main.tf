resource "akamai_dns_zone" "dns_zone" {
  count          = lower(var.type) == "primary" ? 1 : 0
  contract       = var.contract
  zone           = var.zone
  type           = lower(var.type)
  group          = var.group
  sign_and_serve = var.sns
}
