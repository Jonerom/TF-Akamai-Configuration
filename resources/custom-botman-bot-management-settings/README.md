# custom-botman-bot-management-settings

Provision and manage granular Akamai Bot Management (Botman) settings for a specific Security Policy using a custom declarative Go tool. This module is designed to substitute and improve upon the native `akamai_botman_bot_management_settings` resource.

---

## Table of contents
- [Overview](#overview)
- [Purpose](#purpose)
- [Inputs](#inputs)
  - [Non‑optional inputs](#non-optional-inputs)
  - [Optional inputs](#optional-inputs)
- [Outputs](#outputs)
- [Build & Binary Management](#build--binary-management)
- [Testing & validation](#testing--validation)
- [Module dependencies](#module-dependencies)
- [Security considerations](#security-considerations)
- [Additional resources](#additional-resources)

---

## Overview

This module acts as a wrapper around a custom Go binary (`bot-management-settings`) that interacts directly with the Akamai Application Security API. It replaces the standard `akamai_botman_bot_management_settings` resource to provide a more robust, declarative approach to managing Bot Management settings.

It allows for the configuration of specific settings (such as "Active Detections", "Browser Validation", and "Transactional Endpoints") with stricter state guarantees than the standard provider.

**Core Logic & State Enforcement:**
1.  **Dynamic Versioning:** Automatically detects the latest editable version of the security configuration.
2.  **Strict Declarative State:** Missing optional boolean values are explicitly sent as `false`, ensuring no old configuration artifacts remain.
3.  **Verification:** Performs a read-after-write check to guarantee the settings on the platform match the Terraform state.


**Key improvements over the standard resource:**
1.  **Direct Value Handling:** Unlike the original resource, which relied on external JSON templates and complex `templatefile` interpolations (e.g., `bot_management_settings = templatefile(...)`), this module accepts direct, native Terraform values (booleans) as inputs.
2.  **Dynamic Payload Generation:** It constructs the JSON payload dynamically at runtime. This eliminates the need to maintain static JSON template files or create complex scripts to handle "optional" values, ensuring that the payload is always valid regardless of which optional arguments are provided.
3.  **Resilience to Naming Convention Issues:** By handling the HCL-to-JSON transformation internally within the Go binary, the module avoids common pitfalls related to casing mismatches (HCL snake_case vs. JSON camelCase) that often cause failures in raw template interpolations.

---

## Purpose

- **Substitute `akamai_botman_bot_management_settings`:** Provide a reliable alternative for managing Botman settings when the native resource lacks granularity or idempotency.
- **Enforce Idempotency:** Guarantee that the Applied state is the Exact state (e.g., if you remove `enable_browser_validation` from code, it is disabled on Akamai, rather than left alone).

---

## Inputs

### Non‑optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| config_id | number | — | The Akamai AppSec Configuration ID. |
| security_policy_id | string | — | The ID of the Security Policy to update (e.g., `PROD_WAF`). |
| enable_bot_management | bool | — | Master switch to enable/disable Bot Management for this policy. |
| third_party_proxy_service_in_use | bool | — | Flag indicating if a 3rd party proxy is upstream. |
| remove_bot_management_cookies | bool | — | Flag to strip Botman cookies from responses. |
| enable_active_detections | bool | — | Flag to enable active client interrogation techniques. |

### Optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| edgerc_path | string | `~/.edgerc` | Path to the local Akamai credentials file. |
| edgerc_section | string | `default` | The section within `.edgerc` to use for authentication. |
| add_akamai_bot_header | bool | `false` | Add the `Akamai-Bot` header to requests. |
| enable_browser_validation | bool | `false` | Enable browser validation challenges. |
| include_transactional_endpoint_requests | bool | `false` | Include transactional endpoints in bot analysis. |
| include_transactional_endpoint_status | bool | `false` | Monitor status of transactional endpoints. |

---

## Outputs

This module currently defines no outputs in `outputs.tf`. The resource utilizes `terraform_data`, which stores the payload hash internally for state tracking.

---

## Build & Binary Management

**Important:** This module requires a compiled Go binary (`bot-management-settings`) to function. Terraform cannot run raw `.go` files directly.

### Initial Setup
Before running `terraform apply` for the first time (or after changing `main.go`), you must compile the tool, s

1. Navigate to the path of the resource to build: `cd resources/custom-botman-bot-management-settings`
2. Initialize the go module `go mod init custom-botman-bot-management-settings`
3. Add module requirements and sums `go mod tidy`
4. Download Akamai dependencies `go get github.com/akamai/AkamaiOPEN-edgegrid-golang/v7/pkg/edgegrid`
5. Build the Go binary `go build -o bot-management-settings.exe main.go`
*(Note: On Linux/Mac, you may omit the .exe extension).*

---

## Testing & validation

- **API Verification:** The Go tool performs an active read-after-write check.
- **Retry Logic:** It polls the API every 5 seconds.
- **Timeout:** If the settings do not match the desired state within 5 minutes, the module will exit with an error, failing the Terraform apply to prevent false positives.

---

## Module dependencies

- **Terraform 1.4+:** Required for the `terraform_data` resource type.
- **Go 1.18+:** Required to build the binary tool.
- **Akamai Credentials:** A valid `~/.edgerc` file must exist on the machine running Terraform.

---

## Security considerations

- **Credential Safety:** This module does **not** accept API secrets (Client Token, Secret, etc.) as variables. This prevents sensitive credentials from being stored in the Terraform state file in plain text.
- **Execution:** The binary runs locally via `local-exec`. Ensure the machine running Terraform is secure and has the appropriate `.edgerc` permissions (`600`).

---

## Additional resources

- Akamai API: Bot Management (PUT) — https://techdocs.akamai.com/bot-manager/referece/put-bot-management-settings
- Akamai API: Bot Management (PUT) — https://techdocs.akamai.com/bot-manager/referece/get-bot-management-settings
. Akamai API: Config version — https://techdocs.akamai.com/application-security/reference/get-version-number 
- Terraform: terraform_data — https://developer.hashicorp.com/terraform/language/resources/terraform-data