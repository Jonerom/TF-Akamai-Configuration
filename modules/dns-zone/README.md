# dns-zone

Create and manage Akamai Edge DNS zones (primary/secondary/SNS) with optional TSIG configuration and outbound zone transfer settings.

---

## Table of contents
- [Overview](#overview)
- [Purpose](#purpose)
- [Inputs](#inputs)
  - [Non‑optional inputs](#non-optional-inputs)
  - [Optional inputs](#optional-inputs)
  - [Validation details](#validation-details)
- [Outputs](#outputs)
- [Testing & validation](#testing--validation)
- [Module dependencies](#module-dependencies)
- [Security considerations](#security-considerations)
- [Additional resources](#additional-resources)

---

## Overview

This module provisions an Edge DNS zone under a specified contract and group, with support for:
- Primary vs secondary zones
- Sign and Serve (SNS) toggle
- TSIG configuration for secure zone transfers
- Outbound zone transfer settings (ACLs, notify targets)

It is the foundational prerequisite for record management and for publishing Akamai delivery hostnames via DNS.

---

## Purpose

- Establish authoritative zones for applications and delivery endpoints.
- Capture zone‑level features and transfer settings in code for repeatability and auditability.
- Provide typed, validated inputs that mirror Akamai Edge DNS resource semantics.

---

## Inputs

### Non‑optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| contract | string | — | Contract under which the zone will live. |
| group | string | — | Group that will own/manage the zone. |
| zone | string | — | Zone name; letters, numbers, `.`, `_`, `-` only (provider regex validated). |

### Optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| type | string | "primary" | Zone type: "primary" or "secondary". |
| comment | string | "Managed by Terraform" | Zone comment metadata. |
| end_customer_id | string | null | Free‑form identifier for the zone. |
| masters | list(string) | [] | Master DNS servers (for secondary zones). |
| sns | bool | false | Enable Sign and Serve (DNSSEC signing managed by Akamai). |
| sns_algorithm | string | null | Algorithm used for Sign and Serve. |
| tsig_key | object | null | TSIG key for secure transfers. |
| outbound_zone_transfer | object | null | Outbound transfer configuration. |
| outbound_zone_transfer_tsig_key | object | null | TSIG key for Outbound transfer. |
| target | string | null | Alias target zone (used for alias zones feature). |

### Validation details

- zone string is regex‑validated to disallow unsupported characters:
  - Allowed: letters, numbers, `.`, `_`, `-`

---

## Outputs

This module currently defines no outputs in outputs.tf.

---

## Module dependencies

- Requires Akamai provider authenticated to the target contract/group/product scope.

---

## Security considerations

- Treat TSIG secrets as sensitive; never store them in plaintext in version control.
- Never embed provider credentials in code.

---

## Additional resources

- Terraform: akamai_dns_zone — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/dns_zone
- Edge DNS API — https://techdocs.akamai.com/edge-dns/reference/api