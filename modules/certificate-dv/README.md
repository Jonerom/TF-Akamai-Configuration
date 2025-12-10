# certificate-dv

CPS (Certificate Provisioning System) enrollment for domain‑validated (DV) certificates to secure Akamai Edge Hostnames.

---

## Table of contents
- [Overview](#overview)
- [Purpose](#purpose)
- [Inputs](#inputs)
  - [Non‑optional inputs](#non-optional-inputs)
  - [Optional inputs](#optional-inputs)
  - [Object field details](#object-field-details)
- [Outputs](#outputs)
- [Testing & validation](#testing--validation)
- [Module dependencies](#module-dependencies)
- [Security considerations](#security-considerations)
- [Additional resources](#additional-resources)

---

## Overview

This module models a CPS DV enrollment to issue and maintain a TLS certificate that Akamai Enhanced/Standard TLS Edge Hostnames can attach to. It enables:
- Defining the certificate’s CN and SANs, including a simple path (single zone + SAN list) or a structured multi‑zone mapping for SANs.
- Producing the validation metadata (primarily DNS) you will publish (typically via Edge DNS) so CPS can validate ownership and issue the certificate.
- Capturing network posture for the certificate.

Pair this with:
- The dns-records module to create the validation records
- The edge-hostname module to bind the issued enrollment to an Enhanced TLS Edge Hostname.

---

## Purpose

- Standardize DV enrollments across environments and teams with typed, validated inputs.
- Encode TLS/network hardening as code.
- Integrate certificate issuance into a pipeline.

---

## Inputs

### Non‑optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| contract | string | — | Akamai Contract ID where the enrollment will be created. |
| name | string | — | Common Name (CN) FQDN for the certificate. |
| secure_network | string | — | 'standard-tls' (non‑PCI) or 'enhanced-tls' (PCI). |
| sni_only | bool | — | Whether the enrollment is SNI‑only. |
| network_configuration | object | — | See object details below. Required object; most fields inside are optional with sensible defaults. |
| csr | object | — | See object details below. Object and fields are optional when they can be derived from organization. |
| organization | object | — | See object details below. Organization identity. |
| admin_contact | object | — | See object details below. Admin contact identity. |
| tech_contact | object | — | See object details below. Technical contact identity. |
| SANs / validation path | zone + sans OR zone_sans_map | — | You must provide either: (1) `zone` (string) and `sans` (list(string)), or (2) `zone_sans_map` (map of zones with SAN records). See details below. |

### Optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| acknowledge_pre_verification_warnings | bool | null | Acknowledge pre‑verification warnings during enrollment. |
| signature_algorithm | string | "SHA-256" | Signature algorithm. |
| allow_duplicate_common_name | bool | null | Allow duplicate CNs. |
| certificate_chain_type | string | null | Chain preference; provider defaults if unset. |
| timeout_certificate_creation | string | null | Override default certificate creation timeout. |
| timeout_certificate_validation | string | null | Override default certificate validation timeout. |

### Object field details


## Object field details

### network_configuration (required object; internal fields mostly optional unless they differ from organization values)

| Field | Type | Default | Notes |
|---|---|---:|---|
| disallowed_tls_versions | list(string) | ["TLSv1", "TLSv1_1"] | TLS versions to disallow for CPS network config. |
| clone_dns_names | bool | null | Direct traffic using all SANs present at enrollment time. |
| geography | string | "core" | Regional footprint: "core", "china+core", or "russia+core". |
| ocsp_stapling | string | null | OCSP stapling: "on", "off", or "not-set". |
| preferred_ciphers | string | null | Preferred cipher set string (provider accepts known identifiers). |
| must_have_ciphers | string | null | Required cipher set string (provider accepts known identifiers). |
| quic_enabled | bool | null | Enable QUIC for the certificate network configuration. |

### csr (Optional object and fields unless they differ from organization values)

| Field | Type | Default | Notes |
|---|---|---:|---|
| preferred_trust_chain | string | null | Preferred trust chain label. |
| country_code | string | null | Country (ISO code). |
| state | string | null | State or province. |
| city | string | null | City. |
| organization | string | null | Organization name. |
| organizational_unit | string | null | Organizational unit (OU). |

### organization (required object)

| Field | Type | Default | Notes |
|---|---|---:|---|
| name | string | — | Organization legal name. |
| phone | string | — | Organization phone number. |
| country_code | string | — | ISO country code. |
| region | string | — | Region or state/province. |
| city | string | — | City. |
| address_line_one | string | — | Street address line 1. |
| address_line_two | string | null | Street address line 2 (optional). |
| postal_code | string | — | Postal/ZIP code. |

### admin_contact (required object; internal fields mostly optional unless they differ from organization values)

| Field | Type | Default | Notes |
|---|---|---:|---|
| organization | string | null | Admin contact organization. |
| title | string | null | Admin contact job title. |
| first_name | string | — | Admin first name. |
| last_name | string | — | Admin last name. |
| phone | string | — | Admin phone number. |
| email | string | — | Admin email address. |
| country_code | string | null | ISO country code. |
| region | string | null | Region or state/province. |
| city | string | null | City. |
| address_line_one | string | null | Street address line 1. |
| address_line_two | string | null | Street address line 2. |
| postal_code | string | null | Postal/ZIP code. |

### tech_contact (required object; internal fields mostly optional unless they differ from organization values)

| Field | Type | Default | Notes |
|---|---|---:|---|
| organization | string | null | Technical contact organization. |
| title | string | null | Technical contact job title. |
| first_name | string | — | Technical first name. |
| last_name | string | — | Technical last name. |
| phone | string | — | Technical phone number. |
| email | string | — | Technical email address. |
| country_code | string | null | ISO country code. |
| region | string | null | Region or state/province. |
| city | string | null | City. |
| address_line_one | string | null | Street address line 1. |
| address_line_two | string | null | Street address line 2. |
| postal_code | string | null | Postal/ZIP code. |

### SANs / validation path (conditional requirement)

| Path | Required fields | Notes |
|---|---|---|
| Simple SANs | zone (string), sans (list(string)) | Provide SAN FQDNs that live under the specified zone; CPS will emit DNS validation details accordingly. |
| Complex SANs | zone_sans_map (map(object({ zone_name = string, records = list(object({ name = string })) }))) | Supports multiple zones; each entry lists record names to validate under the given zone_name. Must contain at least one entry. |

---

## Outputs

This module currently defines no outputs in outputs.tf.

---

## Testing & validation

- SANs/Zone choice validation:
  - Condition: (length(sans) > 0 AND zone != "") OR (length(zone_sans_map) > 0).
  - If neither path is satisfied, Terraform plan will fail with a clear error message.

No other input validations are enforced at plan time by this module; adhere to Akamai CPS constraints for allowable values.

---

## Module dependencies

- Requires Akamai provider authenticated to the target contract/group/product scope.
- Requires an existing zone (dns-zone).
- Typically used with:
  - dns-records modules to publish CPS validation records (DNS method).
  - edge-hostname to bind the issued enrollment to an Enhanced TLS Edge Hostname.

---

## Security considerations

- No secrets required directly by this module, but never embed provider credentials in code.

---

## Additional resources

- Terraform: akamai_cps_enrollment — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/cps_enrollment
- CPS API — https://techdocs.akamai.com/cps/reference/api
- Edge Hostname (certificate binding) — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/edge_hostname
- Edge DNS record (for validation) — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/dns_record