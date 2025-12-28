
data "akamai_contract" "my_contract" {
  group_name = var.akamai_map.akamai_group_name
}

data "akamai_group" "my_group" {
  group_name  = var.akamai_map.akamai_group_name
  contract_id = data.akamai_contract.my_contract.id
}
