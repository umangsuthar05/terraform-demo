terraform {
  cloud {
    hostname     = "vishal-company.scalr.io"
    organization = "env-v0oqh6fgu19qe9nru"

    workspaces {
      name = "demo-prod-01"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Stack = "demo-prod-01"
    }
  }
}

terraform {
  required_providers {
    scalr = {
      source  = "registry.scalr.io/scalr/scalr"
      version = "~> 1.0"
    }
  }
}