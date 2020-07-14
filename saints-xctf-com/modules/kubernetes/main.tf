/**
 * Kubernetes infrastructure for the saintsxctf.com application.
 * Author: Andrew Jarombek
 * Date: 7/13/2020
 */

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = "andrew-jarombek-eks-cluster"
}