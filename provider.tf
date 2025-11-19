terraform {
  required_version = ">= 1.5.0"
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50" # pick a realistic version you use
    }
  }
}
provider "aws" {
  region = "sa-east-1"
}
