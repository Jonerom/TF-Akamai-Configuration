# cp-code

Provision and manage Akamai CP Codes (Control Plane Codes) for usage tracking and billing attribution across Akamai products (e.g., Ion, AMD, Download Delivery).

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
- [product_id notes](#product_id-notes)
- [Module dependencies](#module-dependencies)
- [Security considerations](#security-considerations)
- [Additional resources](#additional-resources)

---

## Overview

CP Codes are long‑lived identifiers tied to a specific Akamai product within a contract and group. They are used to categorize traffic for billing and reporting. This module creates a CP Code under the correct scope and validates the name format according to Akamai restrictions.

Common workflow:
1) Create a CP Code representing an application or traffic segment.
2) Reference the CP Code ID in Properties to ensure usage attribution is correct.
3) Keep CP Codes stable over time while Properties evolve via versioning.

---

## Purpose

- Provide a consistent, validated path to create CP Codes under the right contract, group, and product.
- Decouple CP Code lifecycle (stable identifiers) from Property versioning and activation.
- Enforce name constraints to prevent provider errors and operational friction.

---

## Inputs

### Non‑optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| contract | string | — | Akamai Contract ID under which to create the CP Code. |
| group | string | — | Group ID under which to create the CP Code. |
| product_id | string | — | Product associated with the CP Code. |
| name | string | — | CP Code name; alphanumeric, spaces, dot, hyphen only. |

### Optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| timeout | string | null | Override default update timeout. |

### Validation details

- name must match the regex: `^[a-zA-Z0-9\s\.-]+$` (no commas, underscores, quotes, #, ^, %, etc.).

---

## Outputs

This module currently defines no outputs in outputs.tf.

---

## Testing & validation

- Name format validation occurs in plan; invalid names will fail with a clear error message.
- Ensure `product_id` is valid for the contract by querying allowed products (see resources).

---

## product_id notes

- Product IDs vary by contract entitlements and are required to scope the correct Akamai product.
- Use `akamai_products` data source to enumerate permitted products:
  - https://registry.terraform.io/providers/akamai/akamai/latest/docs/data-sources/products

---

## Module dependencies

- Requires Akamai provider authenticated to the target contract/group/product scope.
- Typically used with:
  - property module via `cp_code_id`.

---

## Security considerations

- No secrets required directly by this module, but never embed provider credentials in code.

---

## Additional resources

- Terraform: akamai_cp_code — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/cp_code
- Data sources:
  - contracts — https://registry.terraform.io/providers/akamai/akamai/latest/docs/data-sources/contracts
  - groups — https://registry.terraform.io/providers/akamai/akamai/latest/docs/data-sources/groups
  - products — https://registry.terraform.io/providers/akamai/akamai/latest/docs/data-sources/products