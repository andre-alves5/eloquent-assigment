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

# --- Dependencies ---

module "test_vpc" {
  source = "../../networking"

  env            = "test"
  project        = "eloquent"
  vpc-cidr-block = "10.3.0.0/16"
  private-subnets = {
    "priv1" = { cidr = "10.3.1.0/24", az = "us-east-1a" }
  }
  public-subnets = {
    "pub1" = { cidr = "10.3.101.0/24", az = "us-east-1a" }
  }
}

# A dummy ALB is needed to get a security group ID
# checkov:skip=CKV2_AWS_5: "This SG is intentionally not attached as it is a dummy resource for plan-based testing."
resource "aws_security_group" "dummy_alb_sg" {
  name   = "test-dummy-alb-sg"
  vpc_id = module.test_vpc.vpc-id
}

# --- Module Under Test ---

module "test_ecs" {
  source = "../" # Go up to the ECS module root

  env                    = "test"
  project                = "eloquent"
  capacity-providers     = ["FARGATE"]
  cpu                    = 256
  memory                 = 512
  network-mode           = "awsvpc"
  max-capacity           = 1
  min-capacity           = 1
  target-cpu-utilization = 50
  desired-count          = 1
  container-port         = 8080
  launch-type            = "FARGATE"
  vpc-id                 = module.test_vpc.vpc-id
  private-subnet-ids     = module.test_vpc.private-subnet-ids
  alb-sg-id              = aws_security_group.dummy_alb_sg.id
  use_fargate_spot       = false
  alb_listener_arn       = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/test-alb/1234567890123456/1234567890123456" # Dummy ARN
}
