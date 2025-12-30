# TF-Akamai-Configuration

A full modular configuration of an Akamai deployment implemented as Terraform modules.

---

## Overview

This repository provides a cohesive set of Terraform modules to provision and operate Akamai components in a consistent, composable way. The modules target common delivery building blocks (Property Manager properties, Edge Hostnames, CP Codes, CPS certificate enrollments, Edge DNS zones/records and Application Security configurations and policies) and are designed to be wired together by a root configuration or higher-level orchestration.

The repository favors:
- Clear module boundaries with typed inputs and predictable outputs
- Explicit orchestration of stateful actions (e.g., activations, certificate validation) by the caller
- Compatibility with CI/CD pipelines and policy as code
- Readable docs that align with the upstream Akamai Terraform provider and platform APIs

---

## Purpose

- Provide a reusable toolkit of focused Terraform modules for Akamai Delivery, DNS, and certificate management.
- Encourage safe, repeatable deployments by separating concerns (property vs. hostname vs. DNS vs. certificates).
- Offer documentation that maps module intent and inputs to the relevant Akamai provider resources and APIs.

Usage examples, integration patterns, and end-to-end compositions live in the examples/ folder (kept out of module READMEs to keep them lean and reference-focused).

---

## Repository layout

- modules/
  - certificate-dv/ — CPS enrollment for domain-validated certificates used by Edge Hostnames
  - cp-code/ — CP Code creation to track traffic and billing usage; typically referenced by Properties
  - dns-zone/ — Edge DNS zone management (primary/secondary/SNS)
  - dns-records/ — Create single records in an existing DNS zone
  - dns-records-all/ — Flexible all-records interface for record types with rich attributes
  - edge-hostname/ — Edge Hostname creation and TLS/certificate binding
  - property/ — Property Manager configuration with versioning and activation controls
  - security-activation/ — Application Security configuration versioning and activation controls
  - security-config/ — Application Security configuration creation with a default settins template
  - security-policy/ — Application Security policy creation with a default settins template
- resources/
  - appsec-advanced-settings-cookie-settings/ — Application Security configuration advanced settings cookie settings Terraform custom resource
  - custom-botman-bot-management-settings/ — Bot Manager setting Terraform custom resource
  - edge-hostname-waiter/ — Edge Hostname waiter polling Terraform custom resource
- README.md — Overview of the repository

---

## Module dependencies (high-level)

- cp-code → property: Properties typically require a CP Code.
- certificate-dv → edge-hostname: Enhanced TLS Edge Hostnames reference a CPS enrollment.
- dns-zone → dns-records / dns-records-all: Records must be created in an existing zone.
- property ↔ edge-hostname ↔ dns-records: Properties are bound to Edge Hostnames and surfaced via DNS.
- security-config / security-policy → dns-records: Security configurations and policies must be configured with specific DNS targets.
- security-config ↔ security-activation: Only activated security configurations are live.

---

## Security considerations (high-level)

- Do not commit secrets (TSIG keys, CPS private keys, .edgerc, etc.) to source control.
- Prefer environment variables/secrets manager for credentials; mark sensitive variables as `sensitive = true`.
- Enforce least privilege on API clients and regularly rotate credentials and never embed provider credentials in code.

---

## Additional resources

- Akamai Terraform Provider (registry): https://registry.terraform.io/providers/akamai/akamai/latest/docs
- Akamai Terraform Docs (techdocs): https://techdocs.akamai.com/terraform/docs
- Property Manager API: https://techdocs.akamai.com/property-mgr/reference/api
- CPS (Certificates) API: https://techdocs.akamai.com/cps/reference/api
- Edge DNS API: https://techdocs.akamai.com/edge-dns/reference/api
- Applicatino Security API: https://techdocs.akamai.com/application-security/reference/api
- Bot Management API: https://techdocs.akamai.com/bot-manager/reference/api
