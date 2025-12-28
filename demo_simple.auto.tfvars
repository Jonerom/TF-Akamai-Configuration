
# Example of minimum set of variables to deploy an Akamai Edge Hostname with simple configuration.
akamai_map = {
  akamai_group_name = "My Organization-C-0N7RAC7"
  zone_configuration = {
    com = {
      zone_name = "example.com"
    }
    org = {
      zone_name = "example.org"
    }
    net = {
      zone_name = "example.net"
    }
  }
  non_property_dns_configuration = {
    external-sites = {
      zone = "example.com"
      records = [
        { name = "mail", type = "MX", targets = ["mail1.host.com", "mail2.host.com"], priority = 10 },
        { name = "text", type = "TXT", targets = ["v=spf1 include:host.com ~all"] }
      ]
    }
  }
  custom_content_provider_configuration = {
    default = {
      cp_name    = "default-cp"
      product_id = "prd_Fresca"
    }
  }
  security_configuration = {
    name                = "demo-security-configuration"
    support_team_emails = ["bofh@example.com", "soc@example.com"]
  }
  security_policy = {
    default = {
      name = "Default Policy"
    }
  }
  property_configuration = {
    waf-property = {
      property_name                             = "waf"
      support_team_emails                       = ["bofh@example.com", "soc@example.com"]
      product_id                                = "prd_Fresca"
      web_security_name                         = "demo-security-configuration"
      default_json_rule_values                  = { origin_type = "CUSTOMER" }
      basic_json_rules                          = true
      auto_acknowledge_rule_warnings_staging    = true
      auto_acknowledge_rule_warnings_production = true
      certificate_general_configuration         = { certificate_name = "waf-cert" }
      edge_hostname_configuration               = { hostname_affix = "edge" }
      host_configuration = {
        main = {
          zone = "com"
          records = [
            { name = "www", targets = ["10.0.0.10"] },
            { name = "", targets = ["10.0.0.10"] }
          ]
        }
        apis = {
          zone = "org"
          records = [
            { name = "api", targets = ["10.0.0.20", "10.0.0.21", "10.0.0.22"] },
            { name = "site", targets = ["10.0.0.30"] }
          ]
        }
        docs = {
          zone = "net"
          records = [
            { name = "welcome", targets = ["10.0.0.10"] },
            { name = "faq", targets = ["10.0.0.30"] }
          ]
        }
      }
    }
  }
}


organization_details = {
  organization = {
    name             = "My Organization"
    phone            = "+888"
    country_code     = "CC"
    region           = "region"
    city             = "city"
    address_line_one = "Rambla del Poblenou, 154-156"
    postal_code      = "08018"
  }
  admin_contact = {
    first_name = "Admin_name"
    last_name  = "Admin_surname"
    email      = "admin@example.com"
    phone      = "+777"
  }
  tech_contact = {
    first_name = "Tech_name"
    last_name  = "Tech_surname"
    email      = "bofh@example.com"
    phone      = "+666"
  }
}

