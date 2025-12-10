locals {
  basic_json_rule_values = concat([
    data.akamai_property_rules_builder.http2https.json,
    data.akamai_property_rules_builder.augment_insights.json,
    data.akamai_property_rules_builder.accelerate_delivery.json,
    data.akamai_property_rules_builder.offload_origin.json,
    data.akamai_property_rules_builder.strengthen_security.json,
    data.akamai_property_rules_builder.increase_availability.json,
    data.akamai_property_rules_builder.minimize_payload.json,
  ])
}

## HTTP to HTTPS redirect ##
data "akamai_property_rules_builder" "http2https" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name     = "http to https"
      comments = "Redirect http to https traffic"
      behavior {
        redirect {
          mobile_default_choice = "DEFAULT"
          destination_protocol  = "HTTPS"
          destination_hostname  = "SAME_AS_REQUEST"
          destination_path      = "SAME_AS_REQUEST"
          query_string          = "APPEND"
          response_code         = "301"
        }
      }
      criterion {
        request_protocol {
          value = "HTTP"
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}

## Augment Insights ##
locals {
  augment_insights_jsons = concat(
    ["${data.akamai_property_rules_builder.m_pulse.json}"],
    ["${data.akamai_property_rules_builder.edge_scape.json}"],
    ["${data.akamai_property_rules_builder.prefetching.json}"],
  )
}
data "akamai_property_rules_builder" "augment_insights" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name                  = "Augment insights"
      children              = local.augment_insights_jsons
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "m_pulse" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "mPulse"
      behavior {
        m_pulse {
          value {
            enabled                   = true
            require_pci_configuration = false
            loader_version            = "latest"
          }
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "edge_scape" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Content Targeting (EdgeScape)"
      behavior {
        edge_scape {
          value {
            enabled = true
          }
        }
      }
      criterion {
        request_type {
          match_operator = "IS"
          value          = "CLIENT_REQ"
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "log_headers" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Log headers"
      behavior {
        report {
          value {
            log_host             = false
            log_referer          = false
            log_user_agent       = false
            log_accept_language  = false
            log_cookies          = "OFF"
            log_custom_log_field = false
            log_edge_ip          = false
            log_x_forwarded_for  = false
          }
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}

## Accelerate Delivery ##
locals {
  accelerate_delivery_jsons = concat(
    ["${data.akamai_property_rules_builder.dns_refresh.json}"],
    ["${data.akamai_property_rules_builder.protocol_optimization.json}"],
    ["${data.akamai_property_rules_builder.log_headers.json}"],
    ["${data.akamai_property_rules_builder.adaptative_acceleration.json}"],
    ["${data.akamai_property_rules_builder.prefetching.json}"],
  )
}
data "akamai_property_rules_builder" "accelerate_delivery" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name                  = "Accelerate delivery"
      children              = local.accelerate_delivery_jsons
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "dns_refresh" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "DNS Async Refresh"
      behavior {
        dns_async_refresh {
          value {
            enabled = true
            timeout = "2h"
          }
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "protocol_optimization" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Protocol Optimization"
      behavior {
        enhanced_akamai_protocol {
        }
      }
      behavior {
        http2 {
        }
      }
      behavior {
        http3 {
          value {
            enabled = true
          }
        }
      }
      behavior {
        allow_transfer_encoding {
          value {
            enabled = true
          }
        }
      }
      behavior {
        sure_route {
          value {
            enabled = false
          }
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "adaptative_acceleration" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Adaptive Acceleration"
      behavior {
        adaptative_acceleration {
          value {
            source                    = "MPULSE"
            enable_push               = true
            enable_preconnect         = true
            ab_logic                  = "DISABLED"
            enable_ro                 = false
            enable_brotli_compression = true
            enable_for_noncacheable   = false
          }
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
locals {
  prefetching_jsons = concat(
    ["${data.akamai_property_rules_builder.prefetching_objects.json}"],
    ["${data.akamai_property_rules_builder.prefetchable_objects.json}"],
  )
}
data "akamai_property_rules_builder" "prefetching" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name                  = "Prefetching"
      children              = local.prefetching_jsons
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "prefetching_objects" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Prefetching objects"
      behavior {
        prefetch {
          value {
            enabled = true
          }
        }
      }
      criterion {
        user_agent {
          match_operator = "IS_NOT_ONE_OF"
          match_wildcard = ["bot", "crawler", "spider"]
        }
      }
      criteria_must_satisfy = "any"
    }
  }
}
data "akamai_property_rules_builder" "prefetchable_objects" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Prefetchable objects"
      behavior {
        prefetchable {
          value {
            enabled = true
          }
        }
      }
      criterion {
        file_extension {
          match_operator = "IS_ONE_OF"
          values         = ["css", "js", "jpg", "jpeg", "jp2", "png", "gif", "svgz", "webp", "eot", "woff", "woff2", "ttf", "otf"]
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}

## Offload origin ##
locals {
  offload_origin_jsons = concat(
    ["${data.akamai_property_rules_builder.css_js.json}"],
    ["${data.akamai_property_rules_builder.fonts.json}"],
    ["${data.akamai_property_rules_builder.images.json}"],
    ["${data.akamai_property_rules_builder.files.json}"],
    ["${data.akamai_property_rules_builder.other_static.json}"],
    ["${data.akamai_property_rules_builder.html.json}"],
    ["${data.akamai_property_rules_builder.http_redirects.json}"],
    ["${data.akamai_property_rules_builder.post_responses.json}"],
    ["${data.akamai_property_rules_builder.graphql.json}"],
    ["${data.akamai_property_rules_builder.uncacheable_objects.json}"],
  )
}
data "akamai_property_rules_builder" "offload_origin" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Offload origin"
      behavior {
        caching {
          value {
            behavior = "NO_STORE"
          }
        }
      }
      behavior {
        tiered_distribution {
          value {
            enabled = false
          }
        }
      }
      behavior {
        validate_entity_tag {
          value {
            enabled = false
          }
        }
      }
      behavior {
        remove_vary {
          value {
            enabled = false
          }
        }
      }
      behavior {
        cache_error {
          value {
            enabled        = true
            ttl            = "10s"
            preserve_stale = true
          }
        }
      }
      behavior {
        cache_key_query_params {
          value {
            behavior = "INCLUDE_ALL_ALPHABETIZE_ORDER"
          }
        }
      }
      behavior {
        prefresh_cache {
          value {
            enabled     = true
            prefreshval = 90
          }
        }
      }
      behavior {
        downstream_cache {
          value {
            behavior       = "ALLOW"
            allow_behavior = "LESSER"
            send_headers   = "CACHE_CONTROL"
            send_private   = false
          }
        }
      }
      behavior {
        modify_via_header {
          value {
            enabled             = true
            modification_option = "REMOVE_HEADER"
          }
        }
      }
      children              = local.offload_origin_jsons
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "css_js" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "CSS and JS"
      behavior {
        caching {
          value {
            behavior        = "MAX_AGE"
            must_revalidate = false
            ttl             = "7d"
          }
        }
      }
      criterion {
        file_extension {
          match_operator = "IS_ONE_OF"
          values         = ["css", "js"]
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "fonts" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Fonts"
      behavior {
        caching {
          value {
            behavior        = "MAX_AGE"
            must_revalidate = false
            ttl             = "30d"
          }
        }
      }
      criterion {
        file_extension {
          match_operator = "IS_ONE_OF"
          values         = ["eot", "woff", "woff2", "ttf", "otf"]
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "images" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Images"
      behavior {
        caching {
          value {
            behavior        = "MAX_AGE"
            must_revalidate = false
            ttl             = "30d"
          }
        }
      }
      criterion {
        file_extension {
          match_operator = "IS_ONE_OF"
          values         = ["jpg", "jpeg", "jp2", "png", "gif", "svgz", "webp"]
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "files" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Files"
      behavior {
        caching {
          value {
            behavior        = "MAX_AGE"
            must_revalidate = false
            ttl             = "7d"
          }
        }
      }
      criterion {
        file_extension {
          match_operator = "IS_ONE_OF"
          values         = ["pdf", "doc", "docx", "odt"]
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "other_static" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Other_static_objects"
      behavior {
        caching {
          value {
            behavior        = "MAX_AGE"
            must_revalidate = false
            ttl             = "7d"
          }
        }
      }
      criterion {
        file_extension {
          match_operator = "IS_ONE_OF"
          values          = [
            "aif", "aiff", "au", "avi", "bin", "bmp", "cab", "carb", "cct", "cdf", "class", "dcr", "dtd", "exe", "flv", "gcf", "gff", "grv", "hdml", "hqx", "ini", "jar", "jxr", "mid", "midi", 
            "mov", "mp3", "mp4", "mpeg", "mpg", "nc", "pict", "pct", "ppc", "pws", "swa", "tif", "tiff", "txt", "vbs", "w32", "wav", "wbmp", "wml", "wmlc", "wmls", "wmlsc", "xsd", "zip"]
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "html" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "HTML"
      behavior {
        caching {
          value {
            behavior = "NO_STORE"
          }
        }
      }
      behavior {
        cache_key_query_params {
          value {
            behavior    = "IGNORE"
            parameters  = ["gclid", "fbclid", "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content"]
            exact_match = true
          }
        }
      }
      criterion {
        file_extension {
          match_operator = "IS_ONE_OF"
          values         = ["html", "htm", "xhtml", "php", "asp", "aspx", "jsp", ""]
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "http_redirects" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Redirects"
      behavior {
        cache_redirect {
          value {
            enabled = false
          }
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "post_responses" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Post responses"
      behavior {
        cache_post {
          value {
            enabled = false
          }
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "graphql" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "GraphQL"
      behavior {
        graphql_caching {
          value {
            enabled = false
          }
        }
      }
      criterion {
        path {
          match_operator = "MATCHES_ONE_OF"
          values         = ["/graphql"]
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "uncacheable_objects" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Uncacheable objects"
      behavior {
        downstream_cache {
          value {
            behavior = "TUNNEL_ORIGIN"
          }
        }
      }
      criterion {
        response_header {
          header_name    = "Cache-Control"
          match_operator = "IS_NOT_ONE_OF"
          values         = ["CACHEABLE"]
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}

## Strengthen security ##
locals {
  strengthen_security_jsons = concat(
    ["${data.akamai_property_rules_builder.allowed_methods.json}"],
    ["${data.akamai_property_rules_builder.obfuscate_debug.json}"],
    ["${data.akamai_property_rules_builder.obfuscate_backend.json}"],
    ["${data.akamai_property_rules_builder.hsts.json}"],
  )
}
data "akamai_property_rules_builder" "strengthen_security" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Strengthen security"
      behavior {
        all_http_in_cache_hierarchy {
          value {
            enabled = true
          }
        }
      }
      children              = local.strengthen_security_jsons
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "allowed_methods" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Obfuscate debug information"
      behavior {
        allow_delete {
          value {
            enabled    = true
            allow_body = true
          }
        }
      }
      behavior {
        allow_options {
          value {
            enabled = true
          }
        }
      }
      behavior {
        allow_patch {
          value {
            enabled = true
          }
        }
      }
      behavior {
        allow_post {
          value {
            enabled                      = true
            allow_without_content_length = false
          }
        }
      }
      behavior {
        allow_put {
          value {
            enabled = true
          }
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "obfuscate_debug" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Obfuscate debug information"
      behavior {
        cache_tag_visible {
          value {
            behavior = "PRAGMA_HEADER"
          }
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "obfuscate_backend" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Obfuscate backend information"
      behavior {
        modify_outgoing_response_header {
          value {
            action                      = "DELETE"
            standard_delete_header_name = "OTHER"
            custom_header_name          = "X-Powered-By"
          }
        }
      }
      behavior {
        modify_outgoing_response_header {
          value {
            action                      = "DELETE"
            standard_delete_header_name = "OTHER"
            custom_header_name          = "Server
            "
          }
        }
      }
      criterion {
        request_header {
          header_name    = "X-Akamai-Debug"
          match_operator = "IS_NOT_ONE_OF"
          values         = ["true"]
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "hsts" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "HSTS"
      behavior {
        http_strict_transport_security {
          value {
            enabled = false
          }
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}

## Increase availability ##
locals {
  increase_availability_jsons = concat(
    ["${data.akamai_property_rules_builder.simulate_failover.json}"],
    ["${data.akamai_property_rules_builder.site_failover.json}"],
    ["${data.akamai_property_rules_builder.origin_health.json}"],
    ["${data.akamai_property_rules_builder.script_management.json}"],
  )
}
data "akamai_property_rules_builder" "increase_availability" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name                  = "Increase availability"
      children              = local.increase_availability_jsons
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "simulate_failover" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Simulate Failover"
      behavior {
        break_connection {
          value {
            enabled = true
          }
        }
      }
      criterion {
        content_delivery_network {
          match_operator = "IS"
          network        = "STAGING"
        }
        request_header {
          header_name    = "breakconnection"
          match_operator = "IS_ONE_OF"
          values         = ["Your-Secret-Here"]
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "site_failover" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Site Failover"
      behavior {
        fail_action {
          value {
            enabled = false
          }
        }
      }
      criterion {
        origin_timeout {
          match_operator = "ORIGIN_TIMED_OUT"
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "origin_health" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Origin Health"
      behavior {
        health_detection {
          value {
            retry_count        = 3
            retry_interval     = "10s"
            maximum_reconnects = 2
          }
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "script_management" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Script Management"
      behavior {
        script_management {
          value {
            enabled = false
          }
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}

## Minimize Payload ##
locals {
  minimize_payload_jsons = concat(
    ["${data.akamai_property_rules_builder.compressible_objects.json}"],
  )
}
data "akamai_property_rules_builder" "minimize_payload" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name                  = "Minimize payload"
      children              = local.minimize_payload_jsons
      criteria_must_satisfy = "all"
    }
  }
}
data "akamai_property_rules_builder" "compressible_objects" {
  dynamic "rule_format_block" {
    for_each = {
      "${local.rule_format_version}" = true
    }
    labels = [rule_format_block.key]
    content {
      name = "Compressible objects"
      behavior {
        gzip_response {
          value {
            behavior = "ORIGIN_RESPONSE"
          }
        }
      }
      criterion {
        content_type {
          match_operator       = "IS_ONE_OF"
          match_wildcard       = true
          match_case_sensitive = false
          values               = [
            "application/*javascript*", "application/*xml*", "application/text*", "application/*json*", "application/vnd-ms-fontobject", "application/vnd.microsoft.icon", 
            "application/x-font-opentype", "application/x-font-truetype", "application/font-ttf", "application/x-font-tff", "application/font-sfnt", "application/x-font-eot*",
            "application/x-tgif", "application/octet-stream*", "font/otf", "font/ttf", "font/eot", "font/opentype", "text/*", "image/svg+xml", "image/vnd.microsoft.icon", "image/x-icon"
          ]
        }
      }
      criteria_must_satisfy = "all"
    }
  }
}