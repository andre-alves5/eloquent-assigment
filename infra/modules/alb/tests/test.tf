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

# The ALB needs a VPC, so we call the networking module first
module "test_vpc" {
  source = "../../networking" # Adjust path to the networking module

  env            = "test"
  project        = "eloquent"
  vpc-cidr-block = "10.2.0.0/16"
  private-subnets = {
    "priv1" = { cidr = "10.2.1.0/24", az = "us-east-1a" }
  }
  public-subnets = {
    "pub1" = { cidr = "10.2.101.0/24", az = "us-east-1a" }
  }
}

module "test_alb" {
  source = "../" # Go up to the ALB module root

  env                        = "test"
  project                    = "eloquent"
  internal                   = false
  lb-type                    = "application"
  enable-deletion-protection = false
  vpc-id                     = module.test_vpc.vpc-id
  public-subnet-ids          = module.test_vpc.public-subnet-ids
  target-group-arn           = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/test/1234567890123456" # Dummy ARN
  certificate_arn            = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"   # Dummy ARN
  log_bucket_name            = "dummy-log-bucket"
}
