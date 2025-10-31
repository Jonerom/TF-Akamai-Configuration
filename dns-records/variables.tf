variable "zone" {
  description = "Zone name for the DNS record, e.g., example.com"
  type = string
}
variable "record" {
  description = "DNS record name, e.g., www"
  type = string
}
variable "type" {
  description = "Type of DNS record, e.g., A, CNAME, MX, AKAMAICDN, AKAMAITLC, TXT"
  type = string
}
variable "target_list" { 
  description = "List of target values for the DNS record, e.g., comma separated list of IP addresses or domain names"
  type = list(string) 
}
variable "priority" {
  description = "value for MX record priority"
  type    = number
  default = 1
}
variable "ttl" {
  description = "value for DNS record TTL (time to live) in seconds, default is 30 minutes445"
  type    = number
  default = 1800
}
