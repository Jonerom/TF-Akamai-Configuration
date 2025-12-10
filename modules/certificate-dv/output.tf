output "dns_challenges" {
  value = akamai_cps_dv_enrollment.certificate.dns_challenges
}

output "http_challenges" {
  value = akamai_cps_dv_enrollment.certificate.http_challenges
}

output "enrollment_id" {
  value = akamai_cps_dv_enrollment.certificate.id
}
