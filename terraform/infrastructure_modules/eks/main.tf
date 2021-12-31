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
  kubeconfig_name = var.cluster_name

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  manage_aws_auth = false

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        },
        {
          namespace = "default"
          labels = {
            WorkerType = "fargate"
          }
        }
      ]
      tags = {
        Owner = "default"
      }
      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
    game-2048 = {
      name = "game-2048"
      selectors = [
        {
          namespace = "game-2048"
        }
      ]
      subnets = var.subnets
      tags = {
        Owner = "game-2048"
      }
    }
  }
}

module "lb-controller" {
  source       = "../../resource_modules/container/eksFromYoung-ook/modules/lb-controller"
  enabled      = false
  cluster_name = module.eks_cluster_fargate.cluster_id
  oidc         = zipmap(
    ["url", "arn"],
    [module.eks_cluster_fargate.cluster_oidc_issuer_url, module.eks_cluster_fargate.oidc_provider_arn]
  )
  tags         = var.tags
}
