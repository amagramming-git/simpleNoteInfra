# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/fargate/main.tf 202112
################################################################################
# EKS Module
################################################################################
module "eks_cluster_fargate" {
  source = "../../resource_modules/container/eks"

  create_eks      = var.create_eks
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  tags            = merge(local.default-tags, var.tags)

  vpc_id          = var.vpc_id
  subnets         = var.subnets
  fargate_subnets = var.fargate_subnets
  kubeconfig_name = var.cluster_name

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa     = var.enable_irsa
  manage_aws_auth = false

  fargate_profiles = {
    fp-default = {
      name = "fp-default"
      selectors = [
        {
          namespace = "default"
        },
        {
          namespace = "kube-system"
        }
      ]
      subnets = var.fargate_subnets
      tags = {}
    }
    # https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/fargate-getting-started.html
    coredns = {
      name = "coredns"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        }
      ]
      subnets = var.fargate_subnets
      tags = {
        Owner = "coredns"
      }
    }
    game-2048 = {
      name = "game-2048"
      selectors = [
        {
          namespace = "game-2048"
        }
      ]
      subnets = var.fargate_subnets
      tags = {
        Owner = "game-2048"
      }
    }
    simple-note = {
      name = "simple-note"
      selectors = [
        {
          namespace = "simple-note"
        }
      ]
      subnets = var.fargate_subnets
      tags = {
        Owner = "simple-note"
      }
    }
  }
}
