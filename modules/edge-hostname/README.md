# edgehostname

Provision Akamai Edge Hostnames and associate them with product scope and (for Enhanced TLS) a CPS enrollment.

---

## Table of contents
- [Overview](#overview)
- [Purpose](#purpose)
- [Inputs](#inputs)
  - [Non‑optional inputs](#non-optional-inputs)
  - [Optional inputs](#optional-inputs)
- [Outputs](#outputs)
- [product_id notes](#product_id-notes)
- [Module dependencies](#module-dependencies)
- [Security considerations](#security-considerations)
- [Additional resources](#additional-resources)

---

## Overview

Edge Hostnames are Akamai network endpoints that Properties bind to and DNS CNAMEs target. This module:
- Creates the Edge Hostname under the correct contract/group/product,
- Associates a CPS enrollment when using Enhanced TLS,
- Exposes federation options (IP behavior), TTL, status notification recipients, and structured use‑case descriptors.

Common workflow:
1) Enroll DV certificate via certificate-dv (CPS).
2) Create Edge Hostname and reference `certificate_enrollment_id` for Enhanced TLS.
3) Publish CNAME to the canonical target via dns-records/dns-records-all.

---

## Purpose

- Standardize Edge Hostname creation with validated inputs and TLS profile linkage.
- Cleanly tie CPS enrollment to hostname in code for auditability and repeatability.
- Capture operational metadata (notification emails, use cases) alongside network posture.

---

## Inputs

### Non‑optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| contract | string | — | Contract scope for the Edge Hostname. |
| group | string | — | Group scope for the Edge Hostname. |
| product_id | string | — | Akamai product ID for the hostname. |
| hostname | string | — | Edge Hostname stem (without Akamai suffix; provider derives final edge hostname). |
| certificate_enrollment_id | string | — | Required for Enhanced TLS edge hostname types. |

### Optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| edge_hostname_type | string | "enhanced" | "enhanced", "standard", "shared", or "non-tls". |
| ip_behavior | string | "IPV_4" | "IPV_4", "IPV6_COMPLIANCE", or "IPV6_PERFORMANCE". |
| ttl | number | null | DNS TTL for the edge hostname. |
| status_update_email | list(string) | null | Comma‑separated recipients for status updates. |
| use_cases | list(object({ option = string, type = string, use_case = string })) | null | Structured metadata for usage classification. |
| timeout | string | null | Override default update timeout. |

---

## Outputs

This module currently defines no outputs in outputs.tf.

---

## product_id notes

- Product IDs vary by contract entitlements and are required to scope the Edge Hostname to the correct Akamai product.
- Use `akamai_products` data source to enumerate permitted products:
  - https://registry.terraform.io/providers/akamai/akamai/latest/docs/data-sources/products

---

## Module dependencies

- Requires Akamai provider authenticated to the target contract/group/product scope.
- Consumes: certificate-dv CPS enrollment for Enhanced TLS (via `certificate_enrollment_id`).
- Typically used with:
  - property module.

---

## Security considerations

- No secrets required directly by this module, but never embed provider credentials in code.

---

## Additional resources

- Terraform: akamai_edge_hostname — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/edge_hostname
- CPS Enrollment — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/cps_enrollment
- Products data source — https://registry.terraform.io/providers/akamai/akamai/latest/docs/data-sources/products
```
