# security-activate

Activate Akamai Application Security (AppSec) configuration changes to a target network (staging or production).

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

This module issues an AppSec activation request for a specific configuration to a chosen network (staging or production). It’s designed to be part of a CI/CD pipeline, gating production activations behind explicit acknowledgements and human‑readable notes, while allowing fast iteration on the staging network.

Common flow:
1) Update the AppSec configuration (security-config) and policies (security-policy).
2) Activate to the staging network for validation.
3) After validation, activate to production with appropriate approvals and warning acknowledgements.

---

## Purpose

- Provide an auditable, parameterized activation step for AppSec changes.
- Support separate staging vs production activation lifecycles.
- Encourage safe rollouts with optional notifications and explicit activation notes.

---

## Inputs

### Non‑optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| config_id | string | — | ID of the AppSec configuration to activate. |
| network | string | — | Target network for activation: "staging" or "production". |

### Optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| activation_note | string | null | Human‑readable note attached to the activation (reason/change set/approval ticket). |
| acknowledge_warnings | bool | null | Acknowledge provider warnings to proceed with activation (typically required for production). |
| notification_emails | list(string) | null | Email recipients to notify upon activation changes. |
| timeout | string | null | Override activation timeout (e.g., "30m") if supported. |

Note: Exact optional fields may vary depending on how the module is implemented in this repository; the table above reflects typical AppSec activation controls. Align with your module’s variables.tf for authoritative names and defaults.

---

## Outputs

This module currently defines no outputs in outputs.tf.

---

## Module dependencies

- Requires: An existing AppSec configuration (security-config) and associated policies (security-policy).
- Typical pipeline:
  - security-config → security-policy → security-activate (staging) → validation → security-activate (production).

---

## Security considerations

- Gate production activations behind explicit approvals and warning acknowledgements.
- Avoid embedding sensitive information in activation notes; use ticket references where possible.
- No secrets required directly by this module, but never embed provider credentials in code.

---

## Additional resources

- Terraform: appsec_activation — https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/appsec_activation
- Application Security API — https://techdocs.akamai.com/application-security/reference/api
- AppSec Activation concepts — consult the AppSec techdocs for activation prerequisites, warnings, and network semantics.