resource "akamai_cp_code" "cp" {
  name        = var.name
  contract_id = var.contract
  group_id    = var.group
  product_id  = var.product_id
  timeouts {
    update = try(var.timeout, null)
  }
}
