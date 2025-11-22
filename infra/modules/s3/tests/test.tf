terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "test_s3" {
  source = "../"

  env         = "test"
  project     = "eloquent"
  bucket_name = "test-log-bucket"
}
