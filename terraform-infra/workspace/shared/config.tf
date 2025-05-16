terraform {
  cloud {
    hostname     = "vishal-company.scalr.io"
    organization = "env-v0oqh6fgu19qe9nru"

    workspaces {
      name = "e2m-2-workspace"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "awscc" {
  # Configuration options
}

terraform {
  required_providers {
    scalr = {
      source  = "registry.scalr.io/scalr/scalr"
      version = "~> 1.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "0.78.0"
    }
  }
}