resource "aws_ecs_service" "service" {
  name             = "${var.env}-eloquent-api-svc"
  cluster          = aws_ecs_cluster.this.id
  task_definition  = aws_ecs_task_definition.this.arn
  desired_count    = var.desired-count
  launch_type      = var.launch-type
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private-subnet-ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "${var.env}-eloquent-app-container"
    container_port   = var.container-port
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.env}-ecs-sg"
  description = "Security group for ECS service tasks"
  vpc_id      = var.vpc-id

  tags = {
    Name = "${var.env}-ecs-sg"
  }

  ingress {
    description     = "Allow ALB to reach container"
    from_port       = var.container-port
    to_port         = var.container-port
    protocol        = "tcp"
    security_groups = [var.alb-sg-id]
  }

  egress {
    description = "Allow outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
