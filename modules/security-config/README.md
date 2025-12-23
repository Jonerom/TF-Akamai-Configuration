# security-config

Create and manage Akamai Application Security (AppSec) configurations, optionally cloning from an existing configuration/version, associating hostnames, and setting foundational advanced settings (evasive path matching, logging, SIEM, pragma header behavior, and more).

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

This module defines an AppSec configuration that becomes the container for one or more security policies. It supports:
- Creating a new configuration or cloning from a specific existing configuration and version.
- Associating hostnames to scope the protection surface.
- Configuring advanced settings such as evasive URL matching, prefetch rules, request body inspection limits, HTTP logging, attack payload logging, SIEM integration, exception lists, and pragma header handling.

Use this as the base for your security posture; the security-policy module then attaches policies (with match targets, WAF settings, bot management, DoS controls, IP/Geo protections, etc.) to this configuration.

---

## Purpose

- Provide a repeatable way to create and maintain AppSec configurations.
- Centralize global AppSec advanced settings as code, separate from per‑policy tuning.
- Support cloning patterns for consistent configuration baselines across environments.

---

## Inputs

### Non‑optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| contract | string | — | Contract ID for AppSec configuration scope. |
| group | string | — | Group ID to own/manage the configuration. |
| name | string | — | Human‑readable name for the AppSec configuration. |

### Optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| description | string | null | Free‑form description of the configuration. |
| create_from_config_id | string | null | ID of an existing AppSec configuration to clone from. |
| create_from_version | number | null | Version of the `create_from_config_id` to clone from. Must be provided together with `create_from_config_id`. |
| hostname_list | list(string) | [] | Hostnames to associate with this configuration. |
| security_config | object | — | Advanced global settings for this configuration. See tables below. |

---

## Object field details

### security_config (object)

Global advanced settings. Most fields are optional and defaulted.

| Field | Type | Default | Notes |
|---|---|---:|---|
| evasive_path_match_enable | bool | true | Enable Evasive URL Request Matching. |
| prefetch_enable_app_layer | bool | true | Enable prefetch requests for application layer. |
| prefetch_all_extensions | bool | false | Prefetch all extensions; when true, `prefetch_extensions` should be empty. |
| prefetch_extensions | list(string) | ["cgi","jsp","aspx","EMPTY_STRING","php","py","asp"] | Extensions to prefetch when `prefetch_all_extensions=false`. |
| prefetch_enable_rate_controls | bool | false | Apply rate controls to prefetch requests. |
| request_body_inspection_limit | string | "32" | Request body inspection limit in KB. Allowed: "default", "8", "16", "32". |
| pii_learning_enable | bool | false | Enable API PII learning. |

HTTP header logging configuration

| Field | Type | Default | Notes |
|---|---|---:|---|
| http_logging.enabled | string | "true" | Enable HTTP header data logging. |
| http_logging.cookies | string | "all" | Cookie header logging: "all" | "none" | "exclude" | "only". |
| http_logging.custom_type | string | "all" | Custom header logging: "all" | "none" | "exclude" | "only". |
| http_logging.standard_type | string | "all" | Standard header logging: "all" | "none" | "exclude" | "only". |

Attack payload logging configuration

| Field | Type | Default | Notes |
|---|---|---:|---|
| attack_payload_logging.enabled | string | "true" | Enable attack payload logging. |
| attack_payload_logging.request_body | string | "ATTACK_PAYLOAD" | "NONE" or "ATTACK_PAYLOAD". |
| attack_payload_logging.response_body | string | "ATTACK_PAYLOAD" | "NONE" or "ATTACK_PAYLOAD". |

SIEM integration

| Field | Type | Default | Notes |
|---|---|---:|---|
| siem_settings_enable | bool | true | Enable SIEM integration. |
| siem_enable_for_all_policies | bool | true | Enable SIEM for all policies. |
| siem_security_policy_ids | list(string) | — | Specific policy IDs; typically used when not enabling SIEM for all policies. |
| siem_id | number | 1 | SIEM integration identifier. |
| siem_include_ja4_fingerprint | bool | false | Include JA4 fingerprint in SIEM logs. |
| siem_exception_list | list(object) | — | Exception categories to exclude from SIEM. See below. |

SIEM exception list entries (each field is a set of strings)

| Field | Type | Default | Notes |
|---|---|---:|---|
| api_request_constraints | set(string) | — | Exclusions for API request constraints. |
| apr_protection | set(string) | — | Exclusions for APR protection. |
| bot_management | set(string) | — | Exclusions for bot management. |
| client_rep | set(string) | — | Exclusions for client reputation. |
| custom_rules | set(string) | — | Exclusions for custom rules. |
| ip_geo | set(string) | — | Exclusions for IP/Geo controls. |
| malware_protection | set(string) | — | Exclusions for malware protection. |
| rate | set(string) | — | Exclusions for rate controls. |
| slow_post | set(string) | — | Exclusions for slow post protection. |
| url_protection | set(string) | — | Exclusions for URL protection. |
| waf | set(string) | — | Exclusions for WAF. |

Pragma header handling

| Field | Type | Default | Notes |
|---|---|---:|---|
| pragma_header.action | string | "REMOVE" | Pragma header action. |
| pragma_header.conditional_operator | string | — | Condition operator: "AND" (all) or "OR" (any). |
| pragma_header.exclude_condition_list | list(string) | — | Conditions to exclude from removal. See techdocs for structure. |

---

## Outputs

This module currently defines no outputs in outputs.tf.

---

## Testing & validation

- Clone constraint:
  - Either both `create_from_config_id` and `create_from_version` are set, or neither. If only one is set, Terraform plan fails with an error.

---

## Module dependencies

- Often used with security-policy to attach policies to this configuration (`config_id`).
- Hostname association here should align with delivery hostnames from property/edgehostname.
- DNS modules publish hostnames used as match targets by policies.

---

## Security considerations

- Limit AppSec API permissions to configuration operations; rotate credentials regularly.
- Review SIEM payload logging and HTTP header logging settings for data exposure risk.
- No secrets required directly by this module, but never embed provider credentials in code.

---

## Additional resources

- Terraform: appsec_configuration — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/appsec_configuration
- Application Security API — https://techdocs.akamai.com/application-security/reference/api
- Advanced settings (pragma header, logging) — see relevant AppSec API endpoints in techdocs