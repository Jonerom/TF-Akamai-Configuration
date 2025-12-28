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
  rules_v2025_10_16 {
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

## Augment Insights ##
locals {
  augment_insights_jsons = concat(
    ["${data.akamai_property_rules_builder.m_pulse.json}"],
    ["${data.akamai_property_rules_builder.edge_scape.json}"],
    ["${data.akamai_property_rules_builder.prefetching.json}"],
  )
}
data "akamai_property_rules_builder" "augment_insights" {
  rules_v2025_10_16 {
    name                  = "Augment insights"
    children              = local.augment_insights_jsons
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "m_pulse" {
  rules_v2025_10_16 {
    name = "mPulse"
    behavior {
      m_pulse {
        enabled        = true
        require_pci    = false
        loader_version = "LATEST"
      }
    }
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "edge_scape" {
  rules_v2025_10_16 {
    name = "Content Targeting (EdgeScape)"
    behavior {
      edge_scape {
        enabled = true
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
data "akamai_property_rules_builder" "log_headers" {
  rules_v2025_10_16 {
    name = "Log headers"
    behavior {
      report {
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
    criteria_must_satisfy = "all"
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
  rules_v2025_10_16 {
    name                  = "Accelerate delivery"
    children              = local.accelerate_delivery_jsons
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "dns_refresh" {
  rules_v2025_10_16 {
    name = "DNS Async Refresh"
    behavior {
      dns_async_refresh {
        enabled = true
        timeout = "2h"
      }
    }
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "protocol_optimization" {
  rules_v2025_10_16 {
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
        enable = true
      }
    }
    behavior {
      allow_transfer_encoding {
        enabled = true
      }
    }
    behavior {
      sure_route {
        enabled = false
      }
    }
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "adaptative_acceleration" {
  rules_v2025_10_16 {
    name = "Adaptive Acceleration"
    behavior {
      adaptive_acceleration {
        source                    = "MPULSE"
        enable_push               = true
        enable_preconnect         = true
        ab_logic                  = "DISABLED"
        enable_ro                 = false
        enable_brotli_compression = true
        enable_for_noncacheable   = false
      }
    }
    criteria_must_satisfy = "all"
  }
}
locals {
  prefetching_jsons = concat(
    ["${data.akamai_property_rules_builder.prefetching_objects.json}"],
    ["${data.akamai_property_rules_builder.prefetchable_objects.json}"],
  )
}
data "akamai_property_rules_builder" "prefetching" {
  rules_v2025_10_16 {
    name                  = "Prefetching"
    children              = local.prefetching_jsons
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "prefetching_objects" {
  rules_v2025_10_16 {
    name = "Prefetching objects"
    behavior {
      prefetch {
        enabled = true
      }
    }
    criterion {
      user_agent {
        match_operator = "IS_NOT_ONE_OF"
        match_wildcard = true
        values         = ["bot", "crawler", "spider"]
      }
    }
    criteria_must_satisfy = "any"
  }
}
data "akamai_property_rules_builder" "prefetchable_objects" {
  rules_v2025_10_16 {
    name = "Prefetchable objects"
    behavior {
      prefetchable {
        enabled = true
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
  rules_v2025_10_16 {
    name = "Offload origin"
    behavior {
      caching {
        behavior = "NO_STORE"
      }
    }
    behavior {
      tiered_distribution {
        enabled = false
      }
    }
    behavior {
      validate_entity_tag {
        enabled = false
      }
    }
    behavior {
      remove_vary {
        enabled = false
      }
    }
    behavior {
      cache_error {
        enabled        = true
        ttl            = "10s"
        preserve_stale = true
      }
    }
    behavior {
      cache_key_query_params {
        behavior = "INCLUDE_ALL_ALPHABETIZE_ORDER"
      }
    }
    behavior {
      prefresh_cache {
        enabled     = true
        prefreshval = 90
      }
    }
    behavior {
      downstream_cache {
        behavior       = "ALLOW"
        allow_behavior = "LESSER"
        send_headers   = "CACHE_CONTROL"
        send_private   = false
      }
    }
    behavior {
      modify_via_header {
        enabled             = true
        modification_option = "REMOVE_HEADER"
      }
    }
    children              = local.offload_origin_jsons
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "css_js" {
  rules_v2025_10_16 {
    name = "CSS and JS"
    behavior {
      caching {
        behavior        = "MAX_AGE"
        must_revalidate = false
        ttl             = "7d"
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
data "akamai_property_rules_builder" "fonts" {
  rules_v2025_10_16 {
    name = "Fonts"
    behavior {
      caching {
        behavior        = "MAX_AGE"
        must_revalidate = false
        ttl             = "30d"
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
data "akamai_property_rules_builder" "images" {
  rules_v2025_10_16 {
    name = "Images"
    behavior {
      caching {
        behavior        = "MAX_AGE"
        must_revalidate = false
        ttl             = "30d"
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
data "akamai_property_rules_builder" "files" {
  rules_v2025_10_16 {
    name = "Files"
    behavior {
      caching {
        behavior        = "MAX_AGE"
        must_revalidate = false
        ttl             = "7d"
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
data "akamai_property_rules_builder" "other_static" {
  rules_v2025_10_16 {
    name = "Other_static_objects"
    behavior {
      caching {
        behavior        = "MAX_AGE"
        must_revalidate = false
        ttl             = "7d"
      }
    }
    criterion {
      file_extension {
        match_operator = "IS_ONE_OF"
        values = [
          "aif", "aiff", "au", "avi", "bin", "bmp", "cab", "carb", "cct", "cdf", "class", "dcr", "dtd", "exe", "flv", "gcf", "gff", "grv", "hdml", "hqx", "ini", "jar", "jxr", "mid", "midi",
        "mov", "mp3", "mp4", "mpeg", "mpg", "nc", "pict", "pct", "ppc", "pws", "swa", "tif", "tiff", "txt", "vbs", "w32", "wav", "wbmp", "wml", "wmlc", "wmls", "wmlsc", "xsd", "zip"]
      }
    }
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "html" {
  rules_v2025_10_16 {
    name = "HTML"
    behavior {
      caching {
        behavior = "NO_STORE"
      }
    }
    behavior {
      cache_key_query_params {
        behavior    = "IGNORE"
        parameters  = ["gclid", "fbclid", "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content"]
        exact_match = true
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
data "akamai_property_rules_builder" "http_redirects" {
  rules_v2025_10_16 {
    name = "Redirects"
    behavior {
      cache_redirect {
        enabled = false
      }
    }
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "post_responses" {
  rules_v2025_10_16 {
    name = "Post responses"
    behavior {
      cache_post {
        enabled = false
      }
    }
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "graphql" {
  rules_v2025_10_16 {
    name = "GraphQL"
    behavior {
      graphql_caching {
        enabled = false
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
data "akamai_property_rules_builder" "uncacheable_objects" {
  rules_v2025_10_16 {
    name = "Uncacheable objects"
    behavior {
      downstream_cache {
        behavior = "TUNNEL_ORIGIN"
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
  rules_v2025_10_16 {
    name = "Strengthen security"
    behavior {
      all_http_in_cache_hierarchy {
        enabled = true
      }
    }
    children              = local.strengthen_security_jsons
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "allowed_methods" {
  rules_v2025_10_16 {
    name = "Allowed methods"
    behavior {
      allow_delete {
        enabled    = true
        allow_body = true
      }
    }
    behavior {
      allow_options {
        enabled = true
      }
    }
    behavior {
      allow_patch {
        enabled = true
      }
    }
    behavior {
      allow_post {
        enabled                      = true
        allow_without_content_length = false
      }
    }
    behavior {
      allow_put {
        enabled = true
      }
    }
    behavior {
      web_sockets {
        enabled = true
      }
    }
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "obfuscate_debug" {
  rules_v2025_10_16 {
    name = "Obfuscate debug information"
    behavior {
      cache_tag_visible {
        behavior = "PRAGMA_HEADER"
      }
    }
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "obfuscate_backend" {
  rules_v2025_10_16 {
    name = "Obfuscate backend information"
    behavior {
      modify_outgoing_response_header {
        action                      = "DELETE"
        standard_delete_header_name = "OTHER"
        custom_header_name          = "X-Powered-By"
      }
    }
    behavior {
      modify_outgoing_response_header {
        action                      = "DELETE"
        standard_delete_header_name = "OTHER"
        custom_header_name          = "Server"
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
data "akamai_property_rules_builder" "hsts" {
  rules_v2025_10_16 {
    name = "HSTS"
    behavior {
      http_strict_transport_security {
        enable = false
      }
    }
    criteria_must_satisfy = "all"
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
  rules_v2025_10_16 {
    name                  = "Increase availability"
    children              = local.increase_availability_jsons
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "simulate_failover" {
  rules_v2025_10_16 {
    name = "Simulate Failover"
    behavior {
      break_connection {
        enabled = true
      }
    }
    criterion {
      content_delivery_network {
        match_operator = "IS"
        network        = "STAGING"
      }
    }
    criterion {
      request_header {
        header_name    = "breakconnection"
        match_operator = "IS_ONE_OF"
        values         = ["Your-Secret-Here"]
      }
    }
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "site_failover" {
  rules_v2025_10_16 {
    name = "Site Failover"
    behavior {
      fail_action {
        enabled = false
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
data "akamai_property_rules_builder" "origin_health" {
  rules_v2025_10_16 {
    name = "Origin Health"
    behavior {
      health_detection {
        retry_count        = 3
        retry_interval     = "10s"
        maximum_reconnects = 2
      }
    }
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "script_management" {
  rules_v2025_10_16 {
    name = "Script Management"
    behavior {
      script_management {
        enabled = false
      }
    }
    criteria_must_satisfy = "all"
  }
}

## Minimize Payload ##
locals {
  minimize_payload_jsons = concat(
    ["${data.akamai_property_rules_builder.compressible_objects.json}"],
  )
}
data "akamai_property_rules_builder" "minimize_payload" {
  rules_v2025_10_16 {
    name                  = "Minimize payload"
    children              = local.minimize_payload_jsons
    criteria_must_satisfy = "all"
  }
}
data "akamai_property_rules_builder" "compressible_objects" {
  rules_v2025_10_16 {
    name = "Compressible objects"
    behavior {
      gzip_response {
        behavior = "ORIGIN_RESPONSE"
      }
    }
    criterion {
      content_type {
        match_operator       = "IS_ONE_OF"
        match_wildcard       = true
        match_case_sensitive = false
        values = [
          "application/*javascript*", "application/*xml*", "application/text*", "application/*json*", "application/vnd-ms-fontobject", "application/vnd.microsoft.icon",
          "application/x-font-opentype", "application/x-font-truetype", "application/font-ttf", "application/x-font-tff", "application/font-sfnt", "application/x-font-eot*",
          "application/x-tgif", "application/octet-stream*", "font/otf", "font/ttf", "font/eot", "font/opentype", "text/*", "image/svg+xml", "image/vnd.microsoft.icon", "image/x-icon"
        ]
      }
    }
    criteria_must_satisfy = "all"
  }
}
