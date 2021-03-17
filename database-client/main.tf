/**
 * Kubernetes infrastructure for a client to the SaintsXCTF MySQL database.
 * Author: Andrew Jarombek
 * Date: 3/16/2021
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

locals {
  version = "v1.0.0"
}

#--------------------------------------------------------
# Kubernetes Resources for the SaintsXCTF Database Client
#--------------------------------------------------------

resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "saints-xctf-database-client-deployment"
    namespace = 'saints-xctf'

    labels = {
      version = local.version
      environment = "all"
      application = "saints-xctf"
      task = "database-client"
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
        application = "saints-xctf"
        task = "database-client"
      }
    }

    template {
      metadata {
        labels = {
          version = local.version
          environment = "all"
          application = "saints-xctf"
          task = "database-client"
        }
      }

      spec {
        container {
          name = "saints-xctf-database-client"
          image = "quantumobject/docker-mywebsql:latest"

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

resource "kubernetes_service" "service" {
  metadata {
    name = "saints-xctf-database-client"
    namespace = "saints-xctf"

    labels = {
      version = local.version
      environment = "all"
      application = "saints-xctf"
      task = "database-client"
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
      application = "saints-xctf"
      task = "database-client"
    }
  }
}