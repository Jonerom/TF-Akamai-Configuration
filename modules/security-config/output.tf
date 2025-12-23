output "config_id" {
  value = akamai_appsec_configuration.security_config.id
}

data "akamai_appsec_configuration_version" "versions" {
  config_id = akamai_appsec_configuration.security_config.id
}
output "config_version" {
  value = data.akamai_appsec_configuration_version.versions.latest_version
}
