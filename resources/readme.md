# Akamai Custom Terraform Resources

This repository contains a collection of custom Terraform modules designed to extend, stabilize, and enhance the official Akamai Terraform Provider.

These modules were built to address specific gaps in the standard provider, such as:
* **Missing Features:** Configuring settings not yet exposed by official resources (e.g., AppSec Cookie Settings).
* **Reliability:** Replacing static wait times with active polling (e.g., Edge Hostname Waiter).
* **Granularity & Safety:** Providing declarative control with strict state enforcement for complex settings (e.g., Bot Manager).

---

## Modules Overview

| Module Name | Description | Key Feature |
| :--- | :--- | :--- |
| **[custom-botman-bot-management-settings](./custom_botman_bot_management_settings)** | Manages granular Botman settings for a specific Security Policy. | **Declarative State:** Enforces `false` on missing values; verifies state after update. |
| **[edge-hostname-waiter](./edge_hostname_waiter)** | Pauses Terraform execution until an Edge Hostname is fully propagated. | **Active Polling:** Replaces brittle `time_sleep` with actual API validation. |
| **[appsec-advanced-settings-cookie-settings](./appsec_advanced_settings_cookie_settings)** | Manages "Advanced Settings > Cookie Settings" for AppSec configs. | **Enforcement:** Mandates `automatic` domain and secure traffic flags. |

---

## Usage Guide

### 1. Binary building steps depending on OS

Steps to build the binary (linux)
1. Navigate to the path of the resource to build: `cd <folder_name>`
2. Initialize the go module `go mod init <folder_name>`
3. Add module requirements and sums `go mod tidy`
4. Download Akamai dependencies `go get github.com/akamai/AkamaiOPEN-edgegrid-golang/v7/pkg/edgegrid`
5. Build the Go binary `go build -o <resource_name> main.go`
6. Update main.tf to reflect
```hcl
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/<resource_name> \
  [...]
  }
```

Steps to build the binary (windows)
1. Navigate to the path of the resource to build: `cd resources/<folder_name>`
2. Initialize the go module `go mod init <folder_name>`
3. Add module requirements and sums `go mod tidy`
4. Download Akamai dependencies `go get github.com/akamai/AkamaiOPEN-edgegrid-golang/v7/pkg/edgegrid`
5. Build the Go binary `go build -o <resource_name>.exe main.go`
6. Update main.tf to reflect
```hcl
  provisioner "local-exec" {
    command = <<EOT
      ${path.module}/<resource_name>.exe \
  [...]
  }
```

### 2. Bot Management Settings
*Use this to strictly control Bot Management flags (Active Detections, Browser Validation, etc.) on a per-policy basis.*

```hcl
module "custom_botman_bot_management_settings" {
  source = "./resources/custom_botman_bot_management_settings"
  config_id          = 12345
  security_policy_id = "PROD_WAF"
  enable_bot_management            = true
  third_party_proxy_service_in_use = false
  remove_bot_management_cookies    = true
  enable_active_detections         = true
}
```

### 3. Cookie Security Settings
*Use this to control App Security Cookie setting flag on a configuration.*

```hcl
module "appsec_cookies" {
  source = "./modules/appsec_cookie_settings"
  config_id              = 12345
  use_all_secure_traffic = true
}
```

### 3. Cookie Security Settings
*Use this to track the Edge Hostname creation timming.*

```hcl
module "wait_for_ehm" {
  source = "./modules/edge_hostname_waiter"
  edge_hostname = akamai_edge_hostname.ehm.edge_hostname
  depends_on = [akamai_edge_hostname.ehm]
}
```





