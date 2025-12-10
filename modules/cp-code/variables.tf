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

variable "name" {
  description = "Name of the CP Code to be created. Only letters, numbers, spaces, dots (.), and hyphens (-) are allowed."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9\\s\\.-]+$", var.name))
    error_message = "The string must not contain special characters nor commas (,), underscores (_), quotes ('\"), pound signs (#), carets (^), or percent signs (%). Only letters, numbers, spaces, dots (.), and hyphens (-) are allowed."
  }
}

variable "timeout" {
  description = "Timeout for CP Code update operations overriding default 20m"
  type        = string
  default     = null
}
