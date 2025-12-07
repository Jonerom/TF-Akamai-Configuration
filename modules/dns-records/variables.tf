variable "zone" {
  description = "Zone name for the DNS record, e.g., example.com"
  type        = string
}

variable "record" {
  description = "DNS record name, e.g., www"
  type        = string
}

variable "type" {
  description = "Type of DNS record, e.g., A, CNAME, MX, AKAMAICDN, AKAMAITLC, TXT"
  type        = string
}

variable "ttl" {
  description = "value for DNS record TTL (time to live) in seconds, default is 30 minutes445"
  type        = number
  default     = 1800
}

variable "target_list" {
  description = "List of target values for the DNS record, e.g., comma separated list of IP addresses, domain names, or other values depending on the record type"
  type        = list(string)
}

variable "priority" {
  description = "16-bit integer that specifies priority i (for MX, SRV, etc.), if applicable to all targets for specific DNS records"
  type        = number
  default     = null
}

variable "priority_increment" {
  description = "value for increment when multiple targets are provided with no embedded priority for specific DNS records"
  type        = number
  default     = null
}
