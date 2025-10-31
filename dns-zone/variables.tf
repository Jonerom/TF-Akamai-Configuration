variable "contract" {
  description = "value for contract ID associated with the zone"
  type = string
}
variable "group" {
  description = "value for group ID associated with the zone"
  type = string
}
variable "type" {
  description = "value for zone type, e.g., primary or secondary"
  type    = string
  default = "primary"
}
variable "zone" {
  description = "Zone name to be created, e.g., example.com"
  type = string
}
variable "sns" {
  description = "Enable Sign and Serve (SNS) for the DNS zone"
  type    = bool
  default = false
}
