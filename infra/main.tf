module "vpc" {
  source = "./modules/networking"

  env             = var.env
  project         = var.project_name
  vpc-cidr-block  = var.vpc-cidr-block
  private-subnets = var.private-subnets
  public-subnets  = var.public-subnets
}

module "acm" {
  source = "./modules/acm"

  project     = var.project_name
  domain_name = var.domain_name
}

module "ecr" {
  source = "./modules/ecr"

  env             = var.env
  project         = var.project_name
  repository_name = var.ecr_repository_name
}

module "s3" {
  source = "./modules/s3"

  env         = var.env
  project     = var.project_name
  bucket_name = var.log_bucket_name
}

module "alb" {
  source = "./modules/alb"

  env                        = var.env
  project                    = var.project_name
  internal                   = var.internal
  lb-type                    = var.lb-type
  enable-deletion-protection = var.enable-deletion-protection
  vpc-id                     = module.vpc.vpc-id
  public-subnet-ids          = module.vpc.public-subnet-ids
  target-group-arn           = module.ecs.target-group-arn
  certificate_arn            = module.acm.certificate_arn
  log_bucket_name            = module.s3.bucket_name
}

module "ecs" {
  source = "./modules/ecs-fargate"

  env                    = var.env
  project                = var.project_name
  capacity-providers     = var.capacity-providers
  cpu                    = var.cpu
  memory                 = var.memory
  network-mode           = var.network-mode
  max-capacity           = var.max-capacity
  min-capacity           = var.min-capacity
  target-cpu-utilization = var.target-cpu-utilization
  desired-count          = var.desired-count
  container-port         = var.container-port
  launch-type            = var.launch-type
  vpc-id                 = module.vpc.vpc-id
  private-subnet-ids     = module.vpc.private-subnet-ids
  alb-sg-id              = module.alb.alb-sg-id
  use_fargate_spot       = var.use_fargate_spot
}
