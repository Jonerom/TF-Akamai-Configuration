variable "contract" {
  description = "Akamai Contract ID where the CP Code will be created"
  type        = string
}

variable "group" {
  description = "value for group ID where the CP Code will be created"
  type        = string
}

variable "product_id" {
  description = "Akamai Product ID associated with the CP Code"
  type        = string
}

variable "hostname" {
  description = "Edge Hostname to be created without the suffix"
  type        = string
}

variable "edge_hostname_type" {
  description = "Edge Hostname type as per ceritificate type, possible values: enhanced, standard, shared or non-tls"
  type        = string
  default     = "enhanced"
  nullable    = false
}

variable "ip_behavior" {
  description = "IP behavior for the Edge Hostname, possible values: IPV_4 or IPV6_COMPLIANCE / IPV6_PERFORMANCE"
  type        = string
  default     = "IPV_4"
  nullable    = false
}

variable "ttl" {
  description = "value for DNS record TTL (time to live) in seconds, default is 30 minutes445"
  type        = number
  default     = null
}
variable "status_update_email" {
  description = "Email address comma separated list to send status update notifications"
  type        = list(string)
  default     = null
}

variable "use_cases" {
  description = "List of use cases for the Edge Hostname"
  type = list(object({
    option   = string
    type     = string
    use_case = string
  }))
  default = null
}

variable "certificate_enrollment_id" {
  description = "Certificate Enrollment ID to associate with the Edge Hostname, only needed for Enhanced TLS Edge Hostnames type"
  type        = string
}

variable "timeout" {
  description = "Timeout for CP Code update operations overriding default 20m"
  type        = string
  default     = null
}
