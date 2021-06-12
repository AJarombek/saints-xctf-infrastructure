/**
 * Kubernetes infrastructure for a client to the SaintsXCTF MySQL database.
 * Author: Andrew Jarombek
 * Date: 3/16/2021
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = ">= 3.32.0"
    kubernetes = ">= 2.0.2"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/database-client"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = "andrew-jarombek-eks-cluster"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "andrew-jarombek-eks-cluster"
}

data "aws_vpc" "application-vpc" {
  tags = {
    Name = "application-vpc"
  }
}

data "aws_subnet" "kubernetes-dotty-public-subnet" {
  tags = {
    Name = "kubernetes-dotty-public-subnet"
  }
}

data "aws_subnet" "kubernetes-grandmas-blanket-public-subnet" {
  tags = {
    Name = "kubernetes-grandmas-blanket-public-subnet"
  }
}

data "aws_acm_certificate" "saintsxctf-cert" {
  domain = "*.saintsxctf.com"
  statuses = ["ISSUED"]
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command = "aws"
    args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
  }
}

locals {
  version = "v1.0.0"
}

#--------------------------------------------------------
# Kubernetes Resources for the SaintsXCTF Database Client
#--------------------------------------------------------

resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "saints-xctf-database-client-deployment"
    namespace = "saints-xctf"

    labels = {
      version = local.version
      environment = "all"
      application = "saints-xctf-database-client"
    }
  }

  spec {
    replicas = 1
    min_ready_seconds = 10

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge = "1"
        max_unavailable = "0"
      }
    }

    selector {
      match_labels = {
        version = local.version
        environment = "all"
        application = "saints-xctf-database-client"
      }
    }

    template {
      metadata {
        labels = {
          version = local.version
          environment = "all"
          application = "saints-xctf-database-client"
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key = "workload"
                  operator = "In"
                  values = ["development-tests"]
                }
              }
            }
          }
        }

        container {
          name = "saints-xctf-database-client"
          image = "phpmyadmin/phpmyadmin:latest"

          readiness_probe {
            period_seconds = 5
            initial_delay_seconds = 20

            http_get {
              path = "/"
              port = 80
            }
          }

          env {
            name = "PMA_ARBITRARY"
            value = "1"
          }

          port {
            container_port = 80
            protocol = "TCP"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name = "saints-xctf-database-client-service"
    namespace = "saints-xctf"

    labels = {
      version = local.version
      environment = "all"
      application = "saints-xctf-database-client"
    }
  }

  spec {
    type = "NodePort"

    port {
      port = 80
      target_port = 80
      protocol = "TCP"
    }

    selector = {
      application = "saints-xctf-database-client"
    }
  }
}

resource "kubernetes_ingress" "ingress" {
  metadata {
    name = "saints-xctf-database-client-ingress"
    namespace = "saints-xctf"

    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "external-dns.alpha.kubernetes.io/hostname" = "db.saintsxctf.com"
      "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": {\"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/certificate-arn" = data.aws_acm_certificate.saintsxctf-cert.arn
      "alb.ingress.kubernetes.io/healthcheck-path" = "/"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\":80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/healthcheck-protocol": "HTTP"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/security-groups" = aws_security_group.saints-xctf-database-client-lb-sg.id
      "alb.ingress.kubernetes.io/subnets" = "${data.aws_subnet.kubernetes-dotty-public-subnet.id},${data.aws_subnet.kubernetes-grandmas-blanket-public-subnet.id}"
      "alb.ingress.kubernetes.io/target-type" = "instance"
      "alb.ingress.kubernetes.io/tags" = "Name=saints-xctf-database-client-load-balancer,Application=saints-xctf-database-client,Environment=all"
    }

    labels = {
      version = local.version
      environment = "all"
      application = "saints-xctf-database-client"
    }
  }

  spec {
    rule {
      host = "db.saintsxctf.com"

      http {
        path {
          path = "/*"

          backend {
            service_name = "ssl-redirect"
            service_port = "use-annotation"
          }
        }

        path {
          path = "/*"

          backend {
            service_name = "saints-xctf-database-client-service"
            service_port = 80
          }
        }
      }
    }
  }
}

resource "aws_security_group" "saints-xctf-database-client-lb-sg" {
  name = "saints-xctf-database-client-lb-security-group"
  vpc_id = data.aws_vpc.application-vpc.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [var.db_client_access_cidr]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = [var.db_client_access_cidr]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "saints-xctf-database-client-lb-security-group"
    Application = "saints-xctf-database-client"
    Environment = "all"
  }
}