/**
 * Kubernetes infrastructure for the api.saintsxctf.com application.
 * Author: Andrew Jarombek
 * Date: 7/13/2020
 */

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = "andrew-jarombek-eks-cluster"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "andrew-jarombek-eks-cluster"
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

#----------------
# Local Variables
#----------------

locals {
  env = var.prod ? "production" : "development"
  short_env = var.prod ? "prod" : "dev"
  namespace = var.prod ? "saints-xctf" : "saints-xctf-dev"
  short_version = "1.1.3"
  version = "v${local.short_version}"
  account_id = data.aws_caller_identity.current.account_id
}

#---------------------------------------------------
# Kubernetes Resources for the SaintsXCTF Web Server
#---------------------------------------------------

resource "kubernetes_deployment" "nginx-deployment" {
  metadata {
    name = "saints-xctf-api-nginx-deployment"
    namespace = local.namespace

    labels = {
      version = local.version
      environment = local.env
      application = "saints-xctf-api"
      task = "nginx"
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
        environment = local.env
        application = "saints-xctf-api"
        task = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          version = local.version
          environment = local.env
          application = "saints-xctf-api"
          task = "nginx"
        }
      }

      spec {
        container {
          name = "saints-xctf-api-nginx"
          image = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/saints-xctf-api-nginx:${local.short_version}"

          readiness_probe {
            period_seconds = 5
            initial_delay_seconds = 20

            http_get {
              path = "/"
              port = 80
            }
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

resource "kubernetes_deployment" "flask-deployment" {
  metadata {
    name = "saints-xctf-api-flask-deployment"
    namespace = local.namespace

    labels = {
      version = local.version
      environment = local.env
      application = "saints-xctf-api"
      task = "flask"
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
        environment = local.env
        application = "saints-xctf-api"
        task = "flask"
      }
    }

    template {
      metadata {
        labels = {
          version = local.version
          environment = local.env
          application = "saints-xctf-api"
          task = "flask"
        }
      }

      spec {
        container {
          name = "saints-xctf-api-flask"
          image = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/saints-xctf-api-flask:${local.short_version}"

          env {
            name = "FLASK_ENV"
            value = local.env
          }

          env {
            name = "ENV"
            value = local.short_env
          }

          port {
            container_port = 5000
            protocol = "TCP"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name = "saints-xctf-api"
    namespace = local.namespace

    labels = {
      version = local.version
      environment = local.env
      application = "saints-xctf-api"
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
      application = "saints-xctf-api"
      task = "nginx"
    }
  }
}

resource "kubernetes_service" "internal-service" {
  metadata {
    name = "saints-xctf-api-internal"
    namespace = local.namespace

    labels = {
      version = local.version
      environment = local.env
      application = "saints-xctf-api"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port = 5001
      target_port = 80
      protocol = "TCP"
    }

    selector = {
      application = "saints-xctf-api"
      task = "nginx"
    }
  }
}

resource "kubernetes_service" "flask-service" {
  metadata {
    name = "saints-xctf-api-flask"
    namespace = local.namespace

    labels = {
      version = local.version
      environment = local.env
      application = "saints-xctf-api"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port = 5000
      target_port = 5000
      protocol = "TCP"
    }

    selector = {
      application = "saints-xctf-api"
      task = "flask"
    }
  }
}
