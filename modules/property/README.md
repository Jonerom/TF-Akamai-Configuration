# property

Create and manage Akamai Property Manager properties with ruleset JSON (custom or generated defaults with additions).

---

## Table of contents
- [Overview](#overview)
- [Purpose](#purpose)
- [Inputs](#inputs)
  - [Non‑optional inputs](#non-optional-inputs)
  - [Optional inputs](#optional-inputs)
  - [Ruleset definition paths](#ruleset-definition-paths)
  - [Validation details](#validation-details)
- [Outputs](#outputs)
- [Testing & validation](#testing--validation)
- [product_id notes](#product_id-notes)
- [Module dependencies](#module-dependencies)
- [Security considerations](#security-considerations)
- [Additional resources](#additional-resources)

---

## Overview

This module expresses a Property Manager configuration in Terraform. You can either:
- Supply a complete ruleset via `custom_json_rules`.
- Compose generated defaults via `default_json_rule_values` (origin type and related fields) 
  - with `basic_json_rules` to build the base
  - or optionally layer in `additional_json_rules`.

Additionally accepts foundational delivery elements:
- Optional Site Shield
- Optional Edge Hostname references
- Per‑host configuration

---

## Purpose

- Manage Properties declaratively with guardrails around ruleset completeness and origin type correctness.
- Cleanly separate long‑lived identifiers (CP Code, hostnames) from property version activation flows.
- Provide typed inputs mapped to PM API semantics and Akamai Terraform provider.

---

## Inputs

### Non‑optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| contract | string | — | Contract scope for the property. |
| group | string | — | Group scope for the property. |
| product_id | string | — | Akamai product for the property. |
| name | string | — | Property name. |
| support_team_emails | list(string) | — | Notification recipients for property activations. |
| cp_code_id | string | — | Existing CP Code ID to attribute usage. |
| host_configuration | map(object) | — | Host/zone records map. |

### Optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| rule_format | string | null | 'latest' or specific PM rule format (see techdocs). |
| site_shield_name | string | null | Site Shield to associate. |
| edge_hostname | string | null | Edge Hostname reference. |
| edge_hostname_type | string | null | "enhanced", "standard", "shared", or "non-tls". |
| version_notes | string | null | Notes attached to property versions. |
| activation_note | string | null | Notes attached to activations. |
| auto_acknowledge_rule_warnings_staging | bool | null | Auto‑ack staging rule warnings. |
| auto_acknowledge_rule_warnings_production | bool | null | Auto‑ack production rule warnings. |
| timeout_staging_activation | string | null | Override staging activation timeout. |
| timeout_production_activation | string | null | Override production activation timeout. |

### Ruleset definition paths

Choose one:

- Path 1: `custom_json_rules` (string)
  - Complete JSON including the default base rule.

- Path 2: `default_json_rule_values` (object) plus either `basic_json_rules = true` or `additional_json_rules` (list(string))
  - default_json_rule_values requires `origin_type` and origin‑specific fields:
    - CUSTOMER: headers, ports, TLS min version, SNI, verification_mode, etc.
    - NET_STORAGE: account_id, origin_host, optional SPS usage.
    - AKAMAI_OBJECT_STORAGE: container_name, origin_host.

### Validation details

- Name regex: `^[a-zA-Z0-9\._-]+$`.
- Ruleset completeness:
  - Either `custom_json_rules` is non‑empty OR `default_json_rule_values.origin_type` is set.
- Composition guard:
  - If `additional_json_rules` is empty, `basic_json_rules` must be true (at least one must apply).

---

## Outputs

This module currently defines no outputs in outputs.tf.

---

## product_id notes

- Product IDs define which behaviors and rule formats are valid on your property.
- Use `akamai_products` data source to list permitted products for your contract and align `rule_format` accordingly:
  - https://registry.terraform.io/providers/akamai/akamai/latest/docs/data-sources/products

---

## Module dependencies

- Consumes: cp-code via `cp_code_id`.
- Often integrates with: edgehostname and dns‑* for hostnames/CNAME publication and activation sequencing.

---

## Security considerations

- Avoid embedding secrets in rules (use runtime headers/secret injection).
- No secrets required directly by this module, but never embed provider credentials in code.

---

## Additional resources

- Terraform: akamai_property — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/property
- Terraform: akamai_property_activation — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/property_activation
- Rule formats reference — https://techdocs.akamai.com/terraform/docs/pm-ds-rule-formats
- Products data source — https://registry.terraform.io/providers/akamai/akamai/latest/docs/data-sources/products
- Property Manager API — https://techdocs.akamai.com/property-mgr/reference/api