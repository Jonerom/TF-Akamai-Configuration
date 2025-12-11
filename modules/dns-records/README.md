# dns-records

Create and manage a single DNS record within an existing Akamai Edge DNS zone (e.g., A, CNAME, MX, AKAMAICDN, AKAMAITLC, TXT).

---

## Table of contents
- [Overview](#overview)
- [Purpose](#purpose)
- [Inputs](#inputs)
  - [Non‑optional inputs](#non-optional-inputs)
  - [Optional inputs](#optional-inputs)
- [Outputs](#outputs)
- [Module dependencies](#module-dependencies)
- [Security considerations](#security-considerations)
- [Additional resources](#additional-resources)

---

## Overview

This module manages a single DNS record creation and modification.

Common workflow:
1) Ensure zone exists via dns-zone.
2) Create/modify individual records to surface app endpoints or Akamai delivery targets (e.g., CNAME to Edge Hostname).

---

## Purpose

- Provide a minimal and predictable interface to create/update/delete a specific record.
- Make typical delivery patterns straightforward (CNAME to edge hostname, TXT validations, MX, etc.).

---

## Inputs

### Non‑optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| zone | string | — | Zone name, e.g., example.com. |
| record | string | — | Record label, e.g., "www" (empty string "" for apex where supported). |
| type | string | — | Record type: A, CNAME, MX, AKAMAICDN, AKAMAITLC, TXT, etc. |
| target_list | list(string) | — | Targets appropriate to the record type. |

### Optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| ttl | number | 1800 | TTL seconds (default 30 minutes). |
| priority | number | null | For MX/SRV types; uniform priority across all targets. |
| priority_increment | number | null | For MX/SRV types; increment priorities when multiple targets provided. |

---

## Outputs

This module currently defines no outputs in outputs.tf.

---

## Module dependencies

- Requires Akamai provider authenticated to the target contract/group/product scope.
- Requires an existing zone (dns-zone).

---

## Security considerations

- No secrets required directly by this module, but never embed provider credentials in code.

---

## Additional resources

- Terraform: akamai_dns_record — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/dns_record
- Edge DNS API — https://techdocs.akamai.com/edge-dns/reference/api