# Akamai CP Code Terraform Module

## Overview

This Terraform module manages Akamai Content Provider (CP) Codes, which are unique identifiers used for tracking and reporting content delivery across Akamai's platform. CP Codes are essential for monitoring traffic, analyzing performance metrics, and managing billing across different content types or business units.

## Purpose

The cp-code module provides a simplified interface for creating and managing Akamai CP Codes with the following features:

- **Automated CP Code Creation**: Streamlines the creation of CP codes within your Akamai contract and group
- **Name Validation**: Enforces Akamai's naming conventions to prevent errors during deployment
- **Timeout Management**: Configurable timeout settings for update operations
- **Product Association**: Links CP codes to specific Akamai products
- **Output Integration**: Returns the CP code ID for use in other modules (e.g., property configurations)

## Prerequisites

Before using this module, ensure you have:

1. **Terraform**: Version 1.0 or higher installed
2. **Akamai Provider**: Version 9.0.0 or higher configured
3. **Akamai Credentials**: Valid API credentials with permissions to create CP codes
4. **Contract Information**: Your Akamai contract ID
5. **Group Information**: Your Akamai group ID
6. **Product Information**: The product ID associated with your CP code

## Akamai Provider Configuration

This module requires the Akamai Terraform provider to be configured. You can configure it in your root module:

```hcl
provider "akamai" {
  edgerc         = "~/.edgerc"
  config_section = "default"
}
```

Or using environment variables:
- `AKAMAI_HOST`
- `AKAMAI_ACCESS_TOKEN`
- `AKAMAI_CLIENT_TOKEN`
- `AKAMAI_CLIENT_SECRET`

## Usage Examples

### Basic Usage

```hcl
module "my_cp_code" {
  source     = "./modules/cp-code"
  contract   = "ctr_C-1234567"
  group      = "grp_123456"
  name       = "my-content-code"
  product_id = "prd_Fresca"
}
```

### With Custom Timeout

```hcl
module "my_cp_code_with_timeout" {
  source     = "./modules/cp-code"
  contract   = data.akamai_contract.my_contract.id
  group      = data.akamai_group.my_group.id
  name       = "production.website"
  product_id = "prd_Fresca"
  timeout    = "30m"
}
```

### Multiple CP Codes with for_each

```hcl
locals {
  cp_codes = {
    "website-images" = {
      name       = "website-images"
      product_id = "prd_Fresca"
    },
    "website-videos" = {
      name       = "website-videos"
      product_id = "prd_Fresca"
    },
    "api-traffic" = {
      name       = "api.traffic"
      product_id = "prd_Fresca"
    }
  }
}

module "cp_codes" {
  for_each   = local.cp_codes
  source     = "./modules/cp-code"
  contract   = data.akamai_contract.my_contract.id
  group      = data.akamai_group.my_group.id
  name       = each.value.name
  product_id = each.value.product_id
}
```

### Integration with Property Module

This example demonstrates how to use the cp-code module output with the property-waf module:

```hcl
module "custom_cp_code" {
  source     = "./modules/cp-code"
  contract   = data.akamai_contract.my_contract.id
  group      = data.akamai_group.my_group.id
  name       = "my-custom-cp"
  product_id = "prd_Fresca"
}

module "property" {
  source             = "./modules/property-waf"
  contract           = data.akamai_contract.my_contract.id
  group              = data.akamai_group.my_group.id
  name               = "my-property"
  product_id         = "prd_Fresca"
  cp_code_name       = module.custom_cp_code.id
  create_new_cp_code = true
}
```

## Input Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `contract` | `string` | Akamai Contract ID where the CP Code will be created. Format: `ctr_C-XXXXXXX` |
| `group` | `string` | Akamai Group ID where the CP Code will be created. Format: `grp_XXXXXX` |
| `product_id` | `string` | Akamai Product ID associated with the CP Code (e.g., `prd_Fresca`, `prd_SPM`, `prd_Download_Delivery`) |
| `name` | `string` | Name of the CP Code to be created. Must follow Akamai naming conventions (see below) |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `timeout` | `string` | `null` (20m default) | Timeout for CP Code update operations. Examples: `"30m"`, `"1h"` |

## CP Code Naming Conventions

The module enforces Akamai's strict naming requirements for CP codes:

### ✅ Allowed Characters
- **Letters**: a-z, A-Z
- **Numbers**: 0-9
- **Spaces**: ` `
- **Dots**: `.`
- **Hyphens**: `-`

### ❌ Prohibited Characters
- Commas: `,`
- Underscores: `_`
- Quotes: `'` or `"`
- Pound signs: `#`
- Carets: `^`
- Percent signs: `%`
- Other special characters

### Valid Examples
```hcl
name = "my-content-code"        # ✅ Valid
name = "production.website"     # ✅ Valid
name = "API Traffic 2024"       # ✅ Valid
name = "cdn-cache-01"           # ✅ Valid
```

### Invalid Examples
```hcl
name = "my_content_code"        # ❌ Contains underscore
name = "production,website"     # ❌ Contains comma
name = "api-traffic@2024"       # ❌ Contains @
name = "cache#01"               # ❌ Contains #
```

If you provide an invalid name, Terraform will fail during the plan phase with a clear error message:
```
Error: The string must not contain special characters nor commas (,), underscores (_), 
quotes ('"), pound signs (#), carets (^), or percent signs (%). 
Only letters, numbers, spaces, dots (.), and hyphens (-) are allowed.
```

## Outputs

### `id`
- **Type**: `string`
- **Description**: The unique identifier of the created CP Code
- **Format**: `cpc_XXXXXX`
- **Usage**: Can be referenced in other modules or resources that require a CP code

Example output usage:
```hcl
output "cp_code_id" {
  value = module.my_cp_code.id
}
```

## Timeout Configuration

CP Code update operations have a default timeout of 20 minutes. You can override this using the `timeout` variable if you experience longer propagation times:

```hcl
module "my_cp_code" {
  source     = "./modules/cp-code"
  contract   = "ctr_C-1234567"
  group      = "grp_123456"
  name       = "my-content"
  product_id = "prd_Fresca"
  timeout    = "30m"  # Increase timeout to 30 minutes
}
```

Common timeout values:
- `"20m"` - Default (20 minutes)
- `"30m"` - 30 minutes
- `"1h"` - 1 hour

## Common Akamai Product IDs

Here are some commonly used Akamai product IDs:

| Product ID | Product Name |
|------------|--------------|
| `prd_Fresca` | Ion (Premier, Standard) |
| `prd_SPM` | Site Performance Manager |
| `prd_Download_Delivery` | Download Delivery |
| `prd_Adaptive_Media_Delivery` | Adaptive Media Delivery |
| `prd_Rich_Media_Accel` | Rich Media Accelerator |
| `prd_Web_App_Accel` | Web Application Accelerator |

**Note**: Product IDs may vary based on your Akamai contract. Use the Akamai API or Control Center to verify available products for your account.

## Resource Details

This module creates the following Akamai resource:

### `akamai_cp_code.cp`
- **Resource Type**: `akamai_cp_code`
- **Purpose**: Creates a new CP code in your Akamai account
- **API Documentation**: [Akamai CP Code API](https://techdocs.akamai.com/terraform/docs/cp-code)

## Integration Patterns

### Pattern 1: Standalone CP Code
Create a CP code independently for custom reporting:

```hcl
module "analytics_cp_code" {
  source     = "./modules/cp-code"
  contract   = data.akamai_contract.my_contract.id
  group      = data.akamai_group.my_group.id
  name       = "analytics-tracking"
  product_id = "prd_Fresca"
}
```

### Pattern 2: CP Code for Property
Create a CP code specifically for use with a property:

```hcl
module "website_cp_code" {
  source     = "./modules/cp-code"
  contract   = data.akamai_contract.my_contract.id
  group      = data.akamai_group.my_group.id
  name       = "website-prod"
  product_id = "prd_Fresca"
}

module "website_property" {
  source             = "./modules/property-waf"
  contract           = data.akamai_contract.my_contract.id
  group              = data.akamai_group.my_group.id
  name               = "www.example.com"
  product_id         = "prd_Fresca"
  cp_code_name       = module.website_cp_code.id
  create_new_cp_code = true
}
```

### Pattern 3: Multiple CP Codes from Configuration
Use a map-based approach for managing multiple CP codes:

```hcl
variable "cp_code_config" {
  type = map(object({
    name       = string
    product_id = string
    timeout    = optional(string)
  }))
}

module "custom_cp_codes" {
  for_each   = var.cp_code_config
  source     = "./modules/cp-code"
  contract   = data.akamai_contract.my_contract.id
  group      = data.akamai_group.my_group.id
  name       = each.value.name
  product_id = each.value.product_id
  timeout    = try(each.value.timeout, null)
}
```

With `terraform.tfvars`:
```hcl
cp_code_config = {
  "images" = {
    name       = "website-images"
    product_id = "prd_Fresca"
  },
  "videos" = {
    name       = "website-videos"
    product_id = "prd_Fresca"
    timeout    = "30m"
  }
}
```

## Troubleshooting

### Error: Invalid CP Code Name
**Problem**: Terraform validation fails with a naming error.

**Solution**: Ensure your CP code name only contains letters, numbers, spaces, dots, and hyphens. Check the naming conventions section above.

```hcl
# ❌ Wrong
name = "my_cp_code"

# ✅ Correct
name = "my-cp-code"
```

### Error: Timeout During Update
**Problem**: CP code update operations timeout.

**Solution**: Increase the timeout value:

```hcl
module "my_cp_code" {
  source     = "./modules/cp-code"
  # ... other variables ...
  timeout    = "30m"  # Increase from default 20m
}
```

### Error: Invalid Contract or Group ID
**Problem**: Terraform fails with authentication or permission errors.

**Solution**: 
1. Verify your contract and group IDs are correct
2. Ensure your API credentials have permission to create CP codes
3. Check that the contract and group IDs are properly formatted:
   - Contract: `ctr_C-XXXXXXX`
   - Group: `grp_XXXXXX`

```hcl
# Use data sources to fetch valid IDs
data "akamai_contract" "my_contract" {
  group_name = "Your-Group-Name"
}

data "akamai_group" "my_group" {
  group_name  = "Your-Group-Name"
  contract_id = data.akamai_contract.my_contract.id
}
```

### Error: Product Not Available
**Problem**: The specified product ID is not available in your contract.

**Solution**: 
1. Verify the product ID is correct
2. Check your Akamai contract to confirm the product is available
3. Use the Akamai Control Center or API to list available products

### CP Code Not Appearing in Reports
**Problem**: The CP code is created but doesn't appear in Akamai reports.

**Solution**: 
1. Allow up to 24 hours for the CP code to appear in reporting systems
2. Ensure traffic is being routed through the CP code
3. Verify the CP code is properly configured in your property rules

## Best Practices

1. **Descriptive Naming**: Use clear, descriptive names that indicate the purpose of the CP code
   ```hcl
   name = "production-api-traffic"  # Good
   name = "temp123"                 # Avoid
   ```

2. **Use Data Sources**: Fetch contract and group IDs dynamically rather than hardcoding
   ```hcl
   contract = data.akamai_contract.my_contract.id
   group    = data.akamai_group.my_group.id
   ```

3. **Consistent Product IDs**: Use the same product ID across related resources
   ```hcl
   locals {
     product_id = "prd_Fresca"
   }
   
   module "cp_code" {
     source     = "./modules/cp-code"
     product_id = local.product_id
     # ...
   }
   ```

4. **Version Control**: Keep CP code configurations in version control for audit trails

5. **Modular Organization**: Group related CP codes together using `for_each` for easier management

6. **Timeout Considerations**: Only increase timeouts when necessary; the default is usually sufficient

## Module Dependencies

This module has the following dependencies:

- **Terraform**: `>= 1.0`
- **Akamai Provider**: `>= 9.0.0` (source: `akamai/akamai`)

## Security Considerations

1. **Credential Management**: Never commit Akamai API credentials to version control
2. **Access Control**: Ensure API credentials have minimum necessary permissions
3. **Audit Trail**: Use Terraform state management to track CP code creation and changes
4. **Group Isolation**: Use appropriate Akamai groups to isolate CP codes by environment or team

## Additional Resources

- [Akamai Terraform Provider Documentation](https://registry.terraform.io/providers/akamai/akamai/latest/docs)
- [Akamai CP Code Resource](https://registry.terraform.io/providers/akamai/akamai/latest/docs/resources/cp_code)
- [Akamai TechDocs](https://techdocs.akamai.com/)
- [Akamai Control Center](https://control.akamai.com/)

## Contributing

When contributing to this module:
1. Ensure all changes maintain backward compatibility
2. Update this README with any new features or changes
3. Follow Terraform best practices and style guidelines
4. Test changes in a non-production environment first

## License

This module is part of the TF-Akamai-Configuration project. See the repository LICENSE file for details.

## Support

For issues, questions, or contributions, please refer to the main repository:
- **Repository**: Jonerom/TF-Akamai-Configuration
- **Issues**: GitHub Issues section

---

**Last Updated**: 2025-12-07
