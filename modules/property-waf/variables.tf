variable "contract" {
  description = "Akamai Contract ID where the Property will be created"
  type        = string
}

variable "group" {
  description = "value for group ID where the Property will be created"
  type        = string
}

variable "product_id" {
  description = "Akamai Product ID associated with the Property"
  type        = string
}

variable "name" {
  description = "Name of the Property to be created. Only letters, numbers, dots (.), underscores (_) and hyphens (-) are allowed."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9\\._-]+$", var.name))
    error_message = "The string must not contain special characters nor commas (,), spaces, quotes ('\"), pound signs (#), carets (^), or percent signs (%). Only letters, numbers, underscores (_), dots (.), and hyphens (-) are allowed."
  }
}

variable "cp_code_name" {
  description = "Name of the CP Code to be associated with the Property"
  type        = string
}

variable "create_new_cp_code" {
  description = "Flag to indicate whether to create a new CP Code for the Property"
  type        = bool
  default     = true
}

variable "site_shield_name" {
  description = "Name of the Site Shield to be associated with the Property"
  type        = string
  default     = null
}
