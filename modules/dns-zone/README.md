# Akamai DNS Zone Module

This Terraform module creates and manages an Akamai Edge DNS Zone. It is a flexible module that can provision a **Primary**, **Secondary**, or **Alias** zone based on the input variable `type`, minimizing redundant code.

---

## Usage

### Requirements

* **Terraform:** `~> 1.0`
* **Akamai Provider:** `~> 9.0` (or newer)
* **Terraform CLI** installed and configured for Akamai API access.

### Example

To deploy a **Primary** DNS Zone:

```terraform
module "primary_zone" {
  source  = "./modules/akamai-zone" # Adjust path as needed

  # Required Variables
  contract = "ctr_B-XXXXXX"
  group    = "grp_YYYYYY"
  zone     = "my-primary-domain.com"
  
  # Optional: Default is "primary"
  type     = "primary" 
  
  # Optional: Enable DNSSEC (Sign and Serve)
  sns      = true
  sns_algorithm = "RSASHA512" 
}