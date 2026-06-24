/**
 * ECS Infrastructure for the SaintsXCTF MySQL Database Client (PhpMyAdmin).
 * This is for adhoc database administration access only.
 * Author: Andrew Jarombek
 * Date: 6/23/2026
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = "~> 6.2.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "saints-xctf-infrastructure/database-client-ecs"
    region  = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  db_version = "1.0.0"
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
data "aws_acm_certificate" "wildcard_cert" {
  domain   = "*.saintsxctf.com"
  statuses = ["ISSUED"]
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  name        = "saints-xctf-database-client-alb-sg"
  description = "Allow HTTP/HTTPS traffic to database client ALB"
  vpc_id      = data.aws_vpc.application_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.db_client_access_cidr]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.db_client_access_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "saints-xctf-database-client-alb-sg"
    Application = "saints-xctf-database-client"
    Environment = "adhoc"
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "saints-xctf-database-client-ecs-sg"
  description = "Allow traffic from ALB to ECS database client tasks"
  vpc_id      = data.aws_vpc.application_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "saints-xctf-database-client-ecs-sg"
    Application = "saints-xctf-database-client"
    Environment = "adhoc"
  }
}

# Application Load Balancer
resource "aws_lb" "database_client_alb" {
  name               = "saints-xctf-db-client-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    data.aws_subnet.public_subnet_1.id,
    data.aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name        = "saints-xctf-database-client-alb"
    Application = "saints-xctf-database-client"
    Environment = "adhoc"
  }
}

# Target Group
resource "aws_lb_target_group" "database_client_tg" {
  name        = "saints-xctf-db-client-tg"
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

  tags = {
    Name        = "saints-xctf-database-client-tg"
    Application = "saints-xctf-database-client"
    Environment = "adhoc"
  }
}

# HTTPS Listener (primary)
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.database_client_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.wildcard_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.database_client_tg.arn
  }

  tags = {
    Name        = "saints-xctf-database-client-https-listener"
    Application = "saints-xctf-database-client"
    Environment = "adhoc"
  }
}

# HTTP Listener (redirect to HTTPS)
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.database_client_alb.arn
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

  tags = {
    Name        = "saints-xctf-database-client-http-listener"
    Application = "saints-xctf-database-client"
    Environment = "adhoc"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "database_client" {
  name = "saints-xctf-database-client"

  tags = {
    Name        = "saints-xctf-database-client-cluster"
    Application = "saints-xctf-database-client"
    Environment = "adhoc"
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  name               = "ecsDatabaseClientTaskExecutionRole"
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

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "database_client" {
  name              = "/ecs/saints-xctf-database-client"
  retention_in_days = 30

  tags = {
    Name        = "saints-xctf-database-client-logs"
    Application = "saints-xctf-database-client"
    Environment = "adhoc"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "database_client" {
  family                   = "saints-xctf-database-client"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "saints-xctf-database-client"
      image     = "phpmyadmin/phpmyadmin:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "PMA_ARBITRARY"
          value = "1"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.database_client.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "saints-xctf-database-client-task"
    Application = "saints-xctf-database-client"
    Environment = "adhoc"
  }
}

# ECS Service
resource "aws_ecs_service" "database_client" {
  name            = "saints-xctf-database-client"
  cluster         = aws_ecs_cluster.database_client.id
  task_definition = aws_ecs_task_definition.database_client.arn
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
    target_group_arn = aws_lb_target_group.database_client_tg.arn
    container_name   = "saints-xctf-database-client"
    container_port   = 80
  }

  tags = {
    Name        = "saints-xctf-database-client-service"
    Application = "saints-xctf-database-client"
    Environment = "adhoc"
  }

  depends_on = [aws_lb_listener.https_listener]
}

# Route53 Zone Data Source
data "aws_route53_zone" "saintsxctf_com" {
  name         = "saintsxctf.com."
  private_zone = false
}

# Route53 Alias Record
resource "aws_route53_record" "database_client" {
  zone_id = data.aws_route53_zone.saintsxctf_com.zone_id
  name    = "db.saintsxctf.com"
  type    = "A"

  alias {
    name                   = aws_lb.database_client_alb.dns_name
    zone_id                = aws_lb.database_client_alb.zone_id
    evaluate_target_health = true
  }
}


