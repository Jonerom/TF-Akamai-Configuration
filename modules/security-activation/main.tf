resource "akamai_appsec_activations" "my-activation" {
  config_id           = var.config_id
  version             = var.latest_version
  network             = "STAGING"
  note                = var.activation_note != null ? var.activation_note : "Activating on staging"
  notification_emails = var.support_team_emails
}

resource "akamai_appsec_activations" "my-activation" {
  config_id           = var.config_id
  version             = var.latest_version
  network             = "PRODUCTION"
  note                = var.activation_note != null ? var.activation_note : "Activating on production"
  notification_emails = var.support_team_emails
}
