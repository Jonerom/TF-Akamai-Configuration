# custom_appsec_cookie_settings

Provision and manage "Advanced Settings > Cookie Settings" for Akamai Application Security configurations. This module fills a gap in the official Terraform provider by enabling declarative control over global cookie security flags.

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

Currently, the official Akamai Terraform provider lacks a native resource to manage the **"Advanced Settings > Cookie Settings"** endpoint. This forces teams to either manage these settings manually via the UI or leave them unmanaged.

This module resolves that gap by wrapping a custom Go binary (`cookie-settings`) that interacts directly with the Akamai AppSec API. It allows you to enforce secure traffic policies declaratively within your Terraform codebase.

**Key features & guarantees:**
1.  **Dynamic Versioning:** Automatically detects the latest editable version of the security configuration.
2.  **Strict Enforcement:** Enforces the `cookieDomain` to `automatic` (best practice) and toggles `useAllSecureTraffic` based on your input.
3.  **Validation Loop:** Includes a built-in retry mechanism (polling every 5 seconds for up to 5 minutes) to ensure the settings are successfully persisted and retrievable before marking the task as complete.

---

## Purpose

- **Fill Provider Gaps:** Enable management of AppSec Cookie Settings which are not yet supported by standard resources.
- **Enforce Security Standards:** Mandate `useAllSecureTraffic` across configurations to ensure `SameSite=None` and Secure flags are applied to cookies.

---

## Inputs

### Non‑optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| config_id | number | — | The Akamai AppSec Configuration ID to update. |

### Optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| use_all_secure_traffic | bool | `true` | If true, sets Secure flag on all cookies and `SameSite=None` (Required for cross-domain iframes). |
| edgerc_path | string | `~/.edgerc` | Path to the local Akamai credentials file. |
| edgerc_section | string | `default` | The section within `.edgerc` to use for authentication. |

---

## Outputs

This module currently defines no outputs in `outputs.tf`. The resource utilizes `terraform_data`, which stores the payload hash internally for state tracking.

---

## Build & Binary Management

**Important:** This module requires a compiled Go binary (`cookie-updater`) to function. Terraform cannot run raw `.go` files directly.

### Initial Setup
Before running `terraform apply` for the first time (or after changing `main.go`), you must compile the tool:

1. Navigate to the path of the resource to build: `cd modules/appsec_cookie_settings`
2. Initialize the go module: `go mod init appsec_cookie_settings`
3. Download Akamai dependencies: `go get github.com/akamai/AkamaiOPEN-edgegrid-golang/v7`
4. Build the Go binary: `go build -o cookie-updater.exe main.go`
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

- Akamai API: Cookie Settings (PUT) — https://techdocs.akamai.com/application-security/reference/put-advanced-settings-cookie-settings
- Akamai API: Cookie Settings (GET) — https://techdocs.akamai.com/application-security/reference/get-advanced-settings-cookie-settings
. Akamai API: Config version — https://techdocs.akamai.com/application-security/reference/get-version-number 
- Terraform: terraform_data — https://developer.hashicorp.com/terraform/language/resources/terraform-data