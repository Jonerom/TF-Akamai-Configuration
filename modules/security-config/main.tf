### Create the Security Configuration
resource "akamai_appsec_configuration" "security_config" {
  name                  = var.name
  description           = var.description != null ? var.description : "${var.name} security configuration created by Terraform"
  contract_id           = var.contract
  group_id              = var.group
  create_from_config_id = var.create_from_config_id
  create_from_version   = var.create_from_version
  host_names            = var.hostname_list
}

### Establish Evasive URL Request Matching (Configuration -> Advanced Settings -> Inspection)
resource "akamai_appsec_advanced_settings_evasive_path_match" "config_evasive_path_match" {
  config_id         = akamai_appsec_configuration.security_config.config_id
  enable_path_match = var.security_config.evasive_path_match_enable
}

### Establish Prefetch Requests (Configuration -> Advanced Settings -> Inspection)
resource "akamai_appsec_advanced_settings_prefetch" "prefetch" {
  config_id            = akamai_appsec_configuration.security_config.config_id
  enable_app_layer     = var.security_config.prefetch_enable_app_layer
  all_extensions       = !var.security_config.prefetch_enable_app_layer ? var.security_config.prefetch_all_extensions : true
  extensions           = (!var.security_config.prefetch_enable_app_layer || var.security_config.prefetch_all_extensions) ? var.security_config.prefetch_extensions : []
  enable_rate_controls = var.security_config.prefetch_enable_rate_controls
}

### Establish Request size inspection limit (Configuration -> Advanced Settings -> Inspection)
resource "akamai_appsec_advanced_settings_request_body" "request_body" {
  config_id                     = akamai_appsec_configuration.security_config.config_id
  request_body_inspection_limit = try(var.security_config.request_body_inspection_limit, null)
}

### Establish API PII learning (Configuration -> Advanced Settings -> Learning)
resource "akamai_appsec_advanced_settings_pii_learning" "pii_learning" {
  config_id           = akamai_appsec_configuration.security_config.config_id
  enable_pii_learning = var.security_config.pii_learning_enable
}

### Establish HTTP header logging (Configuration -> Advanced Settings -> Logging)
resource "akamai_appsec_advanced_settings_logging" "http_logging" {
  config_id = akamai_appsec_configuration.security_config.config_id
  logging = templatefile("${path.module}/json_templates/http_logging.json", {
    enabled       = var.security_config.http_logging.enabled,
    cookies       = var.security_config.http_logging.cookies,
    custom_type   = var.security_config.http_logging.custom_type,
    standard_type = var.security_config.http_logging.standard_type,
  })
}

### Establish Attack payload logging (Configuration -> Advanced Settings -> Logging)
resource "akamai_appsec_advanced_settings_attack_payload_logging" "attack_payload_logging" {
  config_id = akamai_appsec_configuration.security_config.config_id
  attack_payload_logging = templatefile("${path.module}/json_templates/attack_payload_logging.json", {
    enabled       = var.security_config.attack_payload_logging.enabled,
    request_body  = var.security_config.attack_payload_logging.request_body,
    response_body = var.security_config.attack_payload_logging.response_body
  })
}

### Configure SIEM integration (Configuration -> Advanced Settings -> Logging)
resource "akamai_appsec_siem_settings" "siem_settings" {
  config_id                       = akamai_appsec_configuration.security_config.config_id
  enable_siem                     = var.security_config.siem_settings_enable
  enable_for_all_policies         = var.security_config.siem_enable_for_all_policies
  security_policy_ids             = try(var.security_config.siem_security_policy_ids, null)
  siem_id                         = var.security_config.siem_id
  include_ja4_fingerprint_to_siem = try(var.security_config.siem_include_ja4_fingerprint, null)
  exceptions                      = try(var.security_config.siem_exception_list, null)
}

### Establish Strip Pragma Debug Headers (Configuration -> Advanced Settings -> Platform Security)
resource "akamai_appsec_advanced_settings_pragma_header" "pragma_header" {
  count     = var.security_config.pragma_header.action == "AND" || var.security_config.pragma_header.action == "OR" ? 1 : 0
  config_id = akamai_appsec_configuration.security_config.config_id
  pragma_header = templatefile("${path.module}/json_templates/pragma_header.json", {
    action                 = var.security_config.pragma_header.action,
    conditional_operator   = var.security_config.pragma_header.conditional_operator,
    exclude_condition_list = var.security_config.pragma_header.exclude_condition_list
  })
}

### Establish Response Cookie Secure Attribute (Configuration -> Advanced Settings -> Response Cookie)
# No Terraform resource available at this time
# see https://techdocs.akamai.com/application-security/reference/get-advanced-settings-cookie-settings for API details
# resource "akamai_appsec_advanced_settings_response_cookie_secure_attribute" "response_cookie_secure_attribute" {
#   config_id         = akamai_appsec_configuration.security_config.config_id
#   enable_secure_attr = var.security_config.response_cookie_secure_attribute_enable
# }
