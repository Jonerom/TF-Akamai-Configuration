# security-policy

Define and manage Akamai Application Security (AppSec) policies under a given configuration, including match targets (website/API), IP/Geo protections, DoS rate/slowpost controls, WAF modes and attack groups, bot management, reputation profiles, and logging overrides.
By default, this module deploys a non-intrusive monitoring policy. It captures comprehensive traffic telemetry, enabling teams to assess security requirements and fine-tune rules before moving from 'Log' to 'Deny' mode.  

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

This module attaches a security policy to an existing AppSec configuration, optionally seeded from a prior policy. It supports:
- Defining granular match targets for websites (paths, extensions, hostnames) or APIs (by ID/name).
- Overriding logging and inspection behavior (HTTP headers, attack payload logging, request body limits).
- Enabling and tuning IP/Geo firewall, DoS protections (rate and slowpost), WAF modes and attack groups, reputation defenses, client IP forwarding, and bot management (builtin categories, detections, and custom bot categories).

Policies you define here are applied to match target surfaces associated with the configuration. Combine with the security-config module to set global advanced settings and hostname association.

---

## Purpose

- Express comprehensive AppSec policy controls as code with typed, structured inputs.
- Align policy surfaces (match targets) to hostnames and paths deployed in your delivery configuration.
- Provide a consistent blueprint for policies across environments (dev/stage/prod).

---

## Inputs

### Non‑optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| config_id | string | — | AppSec configuration ID the policy will attach to. |
| policy_name | string | — | Human‑readable policy name. |

### Optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| policy_prefix | string | — | 4‑character alphanumeric prefix enforced by regex. |
| default_settings | bool | false | Whether to assign Akamai default policy settings or create a blank policy. |
| create_from_security_policy_id | string | — | ID of an existing policy to copy from. |
| security_policy | object | — | Detailed policy configuration. See tables below. |

---

## Object field details

### security_policy.match_target (map of objects)

Each map value describes a match target. For `type="website"`, use the `website` block. For `type="api"`, use the `apis` list.

| Field | Type | Default | Notes |
|---|---|---:|---|
| type | string | "website" | Target type: "website" or "api". |
| website.default_file | string | — | Path match rule: "NO_MATCH", "BASE_MATCH", "RECURSIVE_MATCH". |
| website.file_extension_list | list(string) | — | File extensions to match. |
| website.file_path_list | list(string) | — | File paths to match. |
| website.hostname_list | list(string) | — | Hostnames to match. |
| website.is_negative_file_extension_match | string | — | "true" to NOT match listed extensions; "false" to match. |
| website.is_negative_path_match | string | — | "true" to NOT match listed paths; "false" to match. |
| website.bypass_network_list | string | — | Network list to bypass the match target. |
| apis[].api_id | string | — | API ID to match (for API targets). |
| apis[].api_name | string | — | API name to match (for API targets). |

Evasive path and request body overrides

| Field | Type | Default | Notes |
|---|---|---:|---|
| override_evasive_path | bool | false | Override default configuration for evasive path matching. |
| evasive_path_match_enable | bool | — | Enable evasive URL request matching (effective when override is true). |
| override_request_body | bool | — | Override default request body inspection. |
| request_body_inspection_limit | string | — | "default", "8", "16", "32" (effective when override is true). |

HTTP logging override

| Field | Type | Default | Notes |
|---|---|---:|---|
| http_logging.override | bool | false | Override default HTTP logging configuration. |
| http_logging.enabled | string | — | Enable HTTP logging ("true"/"false"). |
| http_logging.cookies | string | — | Cookie logging: "all", "none", "exclude", "only". |
| http_logging.custom_type | string | — | Custom header logging: "all", "none", "exclude", "only". |
| http_logging.standard_type | string | — | Standard header logging: "all", "none", "exclude", "only". |

Attack payload logging override

| Field | Type | Default | Notes |
|---|---|---:|---|
| attack_payload_logging.override | string | "false" | Override default attack logging. |
| attack_payload_logging.enabled | string | — | Enable attack payload logging. |
| attack_payload_logging.request_body | string | — | "NONE" or "ATTACK_PAYLOAD". |
| attack_payload_logging.response_body | string | — | "NONE" or "ATTACK_PAYLOAD". |

Pragma header override

| Field | Type | Default | Notes |
|---|---|---:|---|
| pragma_header.override | string | "false" | Override default pragma header handling. |
| pragma_header.action | string | — | "ADD", "REMOVE", or "NONE". |
| pragma_header.conditional_operator | string | — | "AND" or "OR". |
| pragma_header.exclude_condition_list | list(string) | — | Conditions to exclude. |

IP/Geo firewall

| Field | Type | Default | Notes |
|---|---|---:|---|
| ip_geo_protection_enable | bool | true | Enable IP/Geo firewall. |
| ip_geo_mode | string | "allow" | Mode: "allow" or "block". |
| asn_network_lists.asn_network_lists | list(string) | — | ASN lists to apply. |
| asn_network_lists.action | string | — | Action to apply to ASN lists. |
| geo_network_lists.geo_network_lists | list(string) | — | Geo lists to apply. |
| geo_network_lists.action | string | — | Action to apply to Geo lists. |
| ip_network_lists.ip_network_lists | list(string) | — | IP lists to apply. |
| ip_network_lists.action | string | — | Action to apply to IP lists. |
| exception_ip_network_lists | list(string) | — | Exception IP network lists. |
| ukraine_geo_control_action | string | "none" | "alert", "deny", or "none". |

DoS protections

| Field | Type | Default | Notes |
|---|---|---:|---|
| dos_rate_protection_enable | bool | true | Enable DoS rate protection. |
| dos_rate_policy.ipv4_action | string | — | "deny" or "alert". |
| dos_rate_policy.ipv6_action | string | — | "deny" or "alert". |
| dos_rate_policy.file_path | string | — | File path for custom rate limiting. |
| dos_rate_policy.rate_policy_file_list | list(string) | [] | Additional rate policy files. |
| dos_slowpost_protection_enable | bool | true | Enable DoS slow post protection. |
| dos_slow_rate_action | string | "abort" | Action for slow rate protection. |
| dos_slow_rate_threshold_rate | number | 10 | Threshold rate. |
| dos_slow_rate_threshold_period | number | 60 | Threshold period (seconds). |
| dos_duration_threshold_timeout | number | — | Duration threshold timeout. |

WAF configuration

| Field | Type | Default | Notes |
|---|---|---:|---|
| waf_protection_enable | bool | true | Enable WAF. |
| waf_mode | string | "ASE_AUTO" | "ASE_AUTO"/"AAG" (Akamai updated) or "ASE_MANUAL"/"KRS" (manual updates). |
| waf_attack_group_action_cmdi | string | "deny" | Command Injection. |
| waf_attack_group_action_xss | string | "deny" | Cross‑Site Scripting. |
| waf_attack_group_action_lfi | string | "deny" | Local File Inclusion. |
| waf_attack_group_action_rfi | string | "deny" | Remote File Inclusion. |
| waf_attack_group_action_sql | string | "deny" | SQL Injection. |
| waf_attack_group_action_to | string | "deny" | Outbound attack group. |
| waf_attack_group_action_wat | string | "deny" | Web Application Threats. |
| waf_attack_group_action_wpla | string | "deny" | Platform attack group. |
| waf_attack_group_action_wpv | string | "deny" | Policy Violations. |
| waf_attack_group_action_wpra | string | "deny" | Protocol attack group. |
| waf_penalty_box_enable | bool | true | Enable penalty box. |
| waf_penalty_box_action | string | "deny" | Penalty box action. |

Reputation and API constraints

| Field | Type | Default | Notes |
|---|---|---:|---|
| api_constraints_enable | bool | false | Enable API constraints. |
| reputation_protection_enable | bool | true | Enable reputation protection. |
| reputation_profile_default | list(string) | [] | Default reputation profiles. |
| reputation_profile_default_action | string | "alert" | Action for default profiles: "alert" or "deny". |
| reputation_profile[].name | string | — | Custom reputation profile name. |
| reputation_profile[].action | string | — | "alert" or "deny". |
| reputation_profile[].context | string | — | "WEBATCK", "DOSATCK", "WEBSCRP", "SCANTL". |
| reputation_profile[].shared_ip_handling | string | — | "NON_SHARED", "SHARED_ONLY", or "BOTH". |
| reputation_profile[].threshold | string | — | Sensitivity threshold. |

Client IP forwarding

| Field | Type | Default | Notes |
|---|---|---:|---|
| client_forward_to_http_header | bool | false | Forward client IP to HTTP header. |
| client_forward_shared_ip_to_http_header_siem | bool | false | Forward shared IP to HTTP header for SIEM. |

Bot management settings

| Field | Type | Default | Notes |
|---|---|---:|---|
| bot_management_settings.enable_bot_management | bool | true | Enable bot management. |
| bot_management_settings.add_akamai_bot_header | bool | false | Add Akamai bot header. |
| bot_management_settings.third_party_proxy_service_in_use | bool | true | Mark 3rd‑party proxy usage. |
| bot_management_settings.remove_bot_management_cookies | bool | true | Strip bot management cookies. |
| bot_management_settings.enable_active_detections | bool | true | Enable active detections. |
| bot_management_settings.enable_browser_validation | bool | true | Enable browser validation. |
| bot_management_settings.include_transactional_endpoint_requests | bool | false | Include transactional endpoints. |
| bot_management_settings.include_transactional_endpoint_status | bool | false | Add bot header to transactional endpoints. |
| custom_bot_path | string | "json_files/custom_bots" | Path to custom bot definitions. |
| custom_bot_category[].category_name | string | — | Custom bot category name. |
| custom_bot_category[].action | string | — | "monitor", "tarpit", "slow", "deny". |
| custom_bot_category[].bots | list(string) | — | Bots under this custom category. |

Bot category actions (builtin categories)

| Category | Default |
|---|---:|
| academic_or_research_bots | "monitor" |
| artificial_intelligence_ai_bots | "monitor" |
| automated_shopping_cart_and_sniper_bots | "monitor" |
| business_intelligence_bots | "monitor" |
| ecommerce_search_engine_bots | "monitor" |
| enterprise_data_aggregator_bots | "monitor" |
| financial_account_aggregator_bots | "monitor" |
| financial_services_bots | "monitor" |
| job_search_engine_bots | "monitor" |
| media_or_entertainment_search_bots | "monitor" |
| news_aggregator_bots | "monitor" |
| online_advertising_bots | "monitor" |
| rss_feed_reader_bots | "monitor" |
| seo_analytics_or_marketing_bots | "monitor" |
| site_monitoring_and_web_development_bots | "monitor" |
| social_media_or_blog_bots | "monitor" |
| web_archiver_bots | "monitor" |
| web_search_engine_bots | "monitor" |

Bot transparent detection actions

| Detection | Default | Notes |
|---|---|---|
| impersonators_of_known_bots | "tarpit" |  |
| development_frameworks | "monitor" |  |
| http_libraries | "monitor" |  |
| web_services_libraries | "tarpit" |  |
| open_source_crawlers_scraping_platforms | "tarpit" |  |
| headless_browsers_automation_tools | "monitor" |  |
| declared_bots | "monitor" |  |
| aggressive_web_crawlers | "monitor" |  |
| browser_impersonator | "monitor" |  |
| webscraper_reputation_action | "slow" | Sensitivity: see next row. |
| webscraper_reputation_sensitivity | 4 | Range 1 (most sensitive) to 10 (least). |
| cookie_integrity_failed | "tarpit" |  |
| session_validation_action | "monitor" | Sensitivity below. |
| session_validation_sensitivity | "MEDIUM" | "LOW", "MEDIUM", or "HIGH". |
| javascript_fingerprint_anomaly | "monitor" |  |
| javascript_fingerprint_not_received | "monitor" |  |

JavaScript injection timing

| Field | Default | Notes |
|---|---:|---|
| inject_javascript | "AROUND_PROTECTED_OPERATIONS" | "AROUND_PROTECTED_OPERATIONS", "NEVER", or "ALWAYS". |

---

## Outputs

This module currently defines no outputs in outputs.tf.

---

## Testing & validation

- policy_prefix must be exactly 4 alphanumeric characters:
  - Regex: `^[a-zA-Z0-9]{4}$`
  - Violations fail at plan time.

Guidance (not enforced by Terraform in this module):
- Each match target should specify `type` and a corresponding `website` or `apis` block.
- Request body and logging overrides only take effect when `override_*` fields are set appropriately.

---

## Module dependencies

- Depends on security-config (`config_id`) to attach this policy.
- Match targets should align with hostnames (and paths) managed by property/edgehostname and published via DNS.
- SIEM/logging settings should align with organization logging/retention policies defined at configuration level.

---

## Security considerations

- Review logging overrides to avoid collecting sensitive data unnecessarily.
- Keep network lists (IP/Geo/ASN) under change control and audit changes.
- No secrets required directly by this module, but never embed provider credentials in code.

---

## Additional resources

- Terraform: appsec_policy — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/appsec_policy
- Terraform: appsec_configuration — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/appsec_configuration
- Application Security API — https://techdocs.akamai.com/application-security/reference/api
- Match targets and advanced settings — see relevant AppSec API endpoints in techdocs