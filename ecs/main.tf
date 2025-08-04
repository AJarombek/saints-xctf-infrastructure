/**
 * ECS Infrastructure for the saintsxctf.com website and api.saintsxctf.com API.
 * Author: Andrew Jarombek
 * Date: 7/30/2025
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.12.2"

  required_providers {
    aws = "~> 6.2.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "saints-xctf/infra/ecs"
    region  = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id           = data.aws_caller_identity.current.account_id
  domain_cert          = "saintsxctf.com"
  wildcard_domain_cert = "*.saintsxctf.com"
  ui_version           = "2.0.9"
  api_version          = "2.0.3"
  api_nginx_version    = "2.0.5"
}

# VPC and Subnets
data "aws_vpc" "application_vpc" {
  tags = {
    Name = "application-vpc"
  }
}

data "aws_subnet" "public_subnet_1" {
  tags = {
    Name = "kubernetes-dotty-public-subnet"
  }
}

data "aws_subnet" "public_subnet_2" {
  tags = {
    Name = "kubernetes-grandmas-blanket-public-subnet"
  }
}

# ACM Certificates
data "aws_acm_certificate" "cert" {
  domain   = local.domain_cert
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "wildcard_cert" {
  domain   = local.wildcard_domain_cert
  statuses = ["ISSUED"]
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  name        = "saintsxctf-alb-sg"
  description = "Allow HTTP/HTTPS traffic to ALB"
  vpc_id      = data.aws_vpc.application_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "saintsxctf-ecs-sg"
  description = "Allow traffic from ALB to ECS tasks"
  vpc_id      = data.aws_vpc.application_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancers
resource "aws_lb" "main_alb" {
  name               = "saintsxctf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    data.aws_subnet.public_subnet_1.id,
    data.aws_subnet.public_subnet_2.id
  ]
}

# HTTPS Listener for both UI and API
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ui_tg.arn
  }
}

resource "aws_lb_listener_certificate" "wildcard_cert" {
  listener_arn    = aws_lb_listener.https_listener.arn
  certificate_arn = data.aws_acm_certificate.wildcard_cert.arn
}

# Listener rules for API host and path
resource "aws_lb_listener_rule" "api_host" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
  condition {
    host_header {
      values = ["api.saintsxctf.com"]
    }
  }
}

resource "aws_lb_listener_rule" "api_path" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 20
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
  condition {
    host_header {
      values = ["saintsxctf.com"]
    }
  }
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "api_www_path" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 30
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
  condition {
    host_header {
      values = ["www.saintsxctf.com"]
    }
  }
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "ui_www" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 40
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ui_tg.arn
  }
  condition {
    host_header {
      values = ["www.saintsxctf.com"]
    }
  }
}

# HTTP Listener (redirect to HTTPS)
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Target Groups
resource "aws_lb_target_group" "ui_tg" {
  name        = "saintsxctf-ui-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.application_vpc.id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = 80
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "api_tg" {
  name        = "saintsxctf-api-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.application_vpc.id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = 80
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "saintsxctf" {
  name = "saintsxctf"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name               = "ecsSaintsXCTFTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "ui" {
  family                   = "saintsxctf-ui"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "saintsxctf-ui"
      image = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/saints-xctf-web-nginx:${local.ui_version}"
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/saintsxctf-ui"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "api" {
  family                   = "saintsxctf-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "saintsxctf-api-nginx"
      image = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/saints-xctf-api-nginx:${local.api_nginx_version}"
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/saintsxctf-api-nginx"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name  = "saintsxctf-api-flask"
      image = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/saints-xctf-api-flask:${local.api_version}"
      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/saintsxctf-api-flask"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [
        {
          name  = "FLASK_ENV"
          value = "production"
        },
        {
          name  = "ENV"
          value = "prod"
        }
      ]
    }
  ])
}

# ECS Services
resource "aws_ecs_service" "ui" {
  name            = "saintsxctf-ui"
  cluster         = aws_ecs_cluster.saintsxctf.id
  task_definition = aws_ecs_task_definition.ui.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets = [
      data.aws_subnet.public_subnet_1.id,
      data.aws_subnet.public_subnet_2.id
    ]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ui_tg.arn
    container_name   = "saintsxctf-ui"
    container_port   = 80
  }
}

resource "aws_ecs_service" "api" {
  name            = "saintsxctf-api"
  cluster         = aws_ecs_cluster.saintsxctf.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets = [
      data.aws_subnet.public_subnet_1.id,
      data.aws_subnet.public_subnet_2.id
    ]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.api_tg.arn
    container_name   = "saintsxctf-api-nginx"
    container_port   = 80
  }
}

# Route53 Zone Data Source
data "aws_route53_zone" "saintsxctf_com" {
  name         = "saintsxctf.com."
  private_zone = false
}

# Route53 Alias Records for Combined ALB
resource "aws_route53_record" "saintsxctf_com" {
  zone_id = data.aws_route53_zone.saintsxctf_com.zone_id
  name    = "saintsxctf.com"
  type    = "A"

  alias {
    name                   = aws_lb.main_alb.dns_name
    zone_id                = aws_lb.main_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api_saintsxctf_com" {
  zone_id = data.aws_route53_zone.saintsxctf_com.zone_id
  name    = "api.saintsxctf.com"
  type    = "A"

  alias {
    name                   = aws_lb.main_alb.dns_name
    zone_id                = aws_lb.main_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_saintsxctf_com" {
  zone_id = data.aws_route53_zone.saintsxctf_com.zone_id
  name    = "www.saintsxctf.com"
  type    = "A"

  alias {
    name                   = aws_lb.main_alb.dns_name
    zone_id                = aws_lb.main_alb.zone_id
    evaluate_target_health = true
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "ui" {
  name              = "/ecs/saintsxctf-ui"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "api_nginx" {
  name              = "/ecs/saintsxctf-api-nginx"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "api_flask" {
  name              = "/ecs/saintsxctf-api-flask"
  retention_in_days = 30
}
