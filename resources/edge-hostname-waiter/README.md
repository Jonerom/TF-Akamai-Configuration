# edge-hostname-waiter

Intelligent active waiter for Akamai Edge Hostname creation. This module replaces a static `time_sleep` resources with a dynamic polling mechanism to optimize deployment times and ensure dependency reliability.

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

The standard `akamai_edge_hostname` resource often returns a "success" state before the hostname is fully propagated and visible in the Akamai backend. This typically forces engineers to rely on brittle `time_sleep` resources (e.g., waiting 20 minutes blindly) to prevent subsequent steps (like Property activation) from failing.

This module resolves that inefficiency by wrapping a custom Go binary (`edge-waiter`) that actively polls the Akamai API (`/config-dns/v2/data/edgehostnames`). It verifies the actual existence of the specific Edge Hostname before allowing Terraform to proceed.

**Key improvements over static waiting:**
1.  **Deployment Speed Optimization:** Instead of waiting a fixed amount of time , this module exits as soon as the hostname is ready. Significantly reducing CI/CD pipeline duration.
2.  **Reliability:** It validates that the hostname is actually returned by the API, acting as a functional health check rather than just a timer.
3.  **Configurable Timeout:** Provides a failsafe timeout to prevent pipelines from hanging indefinitely if backend creation fails silently.

---

## Purpose

- **Replace `time_sleep`:** Eliminate arbitrary wait times and the "guesswork" associated with Akamai propagation.
- **Ensure Dependency Readiness:** Guarantee that downstream resources (like `akamai_property`) which depend on the Edge Hostname will not fail due to "Hostname not found" errors.

---

## Inputs

### Non‑optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| edge_hostname | string | — | The full Edge Hostname to wait for (e.g., `www.example.edgesuite.net`). |

### Optional inputs

| Name | Type | Default | Notes |
|---|---|---:|---|
| edgerc_path | string | `~/.edgerc` | Path to the local Akamai credentials file. |
| edgerc_section | string | `default` | The section within `.edgerc` to use for authentication. |
| timeout_minutes | number | `30` | Maximum time to wait before failing the deployment. |
| polling_interval | number | `20` | Time in seconds between API checks. |

---

## Outputs

This module currently defines no outputs in `outputs.tf`. The resource utilizes `terraform_data`, which stores the payload hash internally for state tracking.
Use `depends_on = [module.wait_for_ehm]` in subsequent resources to enforce ordering.

---

## Build & Binary Management

**Important:** This module requires a compiled Go binary (`edge-waiter`) to function. Terraform cannot run raw `.go` files directly.

### Initial Setup
Before running `terraform apply` for the first time (or after changing `main.go`), you must compile the tool:

1. Navigate to the path of the resource to build: `cd resources/edge-hostname-waiter`
2. Initialize the go module `go mod init edge-hostname-waiter`
3. Add module requirements and sums `go mod tidy`
4. Download Akamai dependencies `go get github.com/akamai/AkamaiOPEN-edgegrid-golang/v7/pkg/edgegrid`
5. Build the Go binary `go build -o ehm_waiter.exe main.go`
*(Note: On Linux/Mac, you may omit the .exe extension).*

---

## Testing & validation

- **API Verification:** The Go tool performs an active read-after-write check.
- **Retry Logic:** It polls the API every 20 seconds.
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

- Akamai API: Edge Hostnmae — https://techdocs.akamai.com/property-mgr/reference/get-edgehostname
- Terraform: terraform_data — https://developer.hashicorp.com/terraform/language/resources/terraform-data