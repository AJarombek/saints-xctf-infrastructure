/**
 * Kubernetes Ingress infrastructure for the saintsxctf.com application.
 * Author: Andrew Jarombek
 * Date: 10/9/2020
 */

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

/* You are as strong as they get */
data "aws_subnet" "kubernetes-grandmas-blanket-public-subnet" {
  tags = {
    Name = "kubernetes-grandmas-blanket-public-subnet"
  }
}

data "aws_acm_certificate" "saintsxctf-cert" {
  domain = local.domain_cert
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "saintsxctf-dev-cert" {
  domain = local.dev_domain_cert
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "saintsxctf-api-cert" {
  domain = local.api_domain_cert
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "saintsxctf-api-dev-cert" {
  domain = local.dev_api_domain_cert
  statuses = ["ISSUED"]
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
  load_config_file = false
}

#----------------
# Local Variables
#----------------

locals {
  short_env = var.prod ? "prod" : "dev"
  env = var.prod ? "production" : "development"
  namespace = var.prod ? "saints-xctf" : "saints-xctf-dev"
  host1 = var.prod ? "saintsxctf.com" : "dev.saintsxctf.com"
  host2 = var.prod ? "www.saintsxctf.com" : "www.dev.saintsxctf.com"
  host3 = var.prod ? "api.saintsxctf.com" : "dev.api.saintsxctf.com"
  host4 = var.prod ? "www.api.saintsxctf.com" : "www.dev.api.saintsxctf.com"
  hostname = "${local.host1},${local.host2},${local.host3},${local.host4}"
  certificates = "${local.cert_arn},${local.dev_cert_arn},${local.api_cert_arn},${local.dev_api_cert_arn}"
  short_version = "1.2.0"
  version = "v${local.short_version}"
  account_id = data.aws_caller_identity.current.account_id
  domain_cert = "*.saintsxctf.com"
  dev_domain_cert = "*.dev.saintsxctf.com"
  api_domain_cert = "*.api.saintsxctf.com"
  dev_api_domain_cert = "*.dev.api.saintsxctf.com"
  cert_arn = data.aws_acm_certificate.saintsxctf-cert.arn
  dev_cert_arn = data.aws_acm_certificate.saintsxctf-dev-cert.arn
  api_cert_arn = data.aws_acm_certificate.saintsxctf-api-cert.arn
  dev_api_cert_arn = data.aws_acm_certificate.saintsxctf-api-dev-cert.arn
  subnet1 = data.aws_subnet.kubernetes-dotty-public-subnet.id
  subnet2 = data.aws_subnet.kubernetes-grandmas-blanket-public-subnet.id
}

#--------------
# AWS Resources
#--------------

resource "aws_security_group" "saints-xctf-com-lb-sg" {
  name = "saints-xctf-com-${local.short_env}-lb-security-group"
  vpc_id = data.aws_vpc.application-vpc.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "saints-xctf-com-${local.short_env}-lb-security-group"
    Application = "saints-xctf-com"
    Environment = local.env
  }
}

#-------------------------------------
# Kubernetes Resources for the Ingress
#-------------------------------------

resource "kubernetes_ingress" "ingress" {
  metadata {
    name = "saints-xctf-com-ingress"
    namespace = local.namespace

    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "external-dns.alpha.kubernetes.io/hostname" = local.hostname
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/certificate-arn" = local.certificates
      "alb.ingress.kubernetes.io/healthcheck-path" = "/login"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\":80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/healthcheck-protocol": "HTTP"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/security-groups" = aws_security_group.saints-xctf-com-lb-sg.id
      "alb.ingress.kubernetes.io/subnets" = "${local.subnet1},${local.subnet2}"
      "alb.ingress.kubernetes.io/target-type" = "instance"
      "alb.ingress.kubernetes.io/tags" = "Name=saints-xctf-com-load-balancer,Application=saints-xctf-com,Environment=${local.env}"
    }

    labels = {
      version = local.version
      environment = local.env
      application = "saints-xctf-com"
    }
  }

  spec {
    rule {
      host = local.host1

      http {
        path {
          path = "/*"

          backend {
            service_name = "saints-xctf-web-service"
            service_port = 80
          }
        }
      }
    }

    rule {
      host = local.host2

      http {
        path {
          path = "/*"

          backend {
            service_name = "saints-xctf-web-service"
            service_port = 80
          }
        }
      }
    }

    rule {
      host = local.host3

      http {
        path {
          path = "/*"

          backend {
            service_name = "saints-xctf-api-service"
            service_port = 80
          }
        }
      }
    }

    rule {
      host = local.host4

      http {
        path {
          path = "/*"

          backend {
            service_name = "saints-xctf-api-service"
            service_port = 80
          }
        }
      }
    }
  }
}