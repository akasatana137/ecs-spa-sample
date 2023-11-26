terraform {
  required_version = "= 1.6.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.0"
    }

    external = {
      source  = "hashicorp/external"
      version = "2.2.2"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile_name
  default_tags {
    tags = {
      application = local.app_name
    }
  }
}
