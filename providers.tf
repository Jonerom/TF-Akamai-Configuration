terraform {
  required_providers {
    akamai = {
      source  = "akamai/akamai"
      version = "= 9.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.7.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "= 0.13.1"
    }
  }
  required_version = ">= 1.0"
}

provider "akamai" {
  edgerc         = "~/.edgerc"
  config_section = "demo"
}
provider "random" {}
provider "time" {}
