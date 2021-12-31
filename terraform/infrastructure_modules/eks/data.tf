# current account ID
data "aws_caller_identity" "current" {}

locals {
    ################################################################################
    # EKS Module
    ################################################################################
    default-tags = merge(
        { 
            "terraform.io" = "managed" 
            "Example"      = var.cluster_name
            "GithubRepo"   = "terraform-aws-eks"
            "GithubOrg"    = "terraform-aws-modules"
        },
        local.eks-owned-tag,
        var.tags
    )
}
## kubernetes tags
locals {
    eks-shared-tag = {
        format("kubernetes.io/cluster/%s", var.cluster_name) = "shared"
    }
    eks-owned-tag = {
        format("kubernetes.io/cluster/%s", var.cluster_name) = "owned"
    }
    # eks-elb-tag = {
    #     "kubernetes.io/role/elb" = "1"
    # }
    # eks-internal-elb-tag = {
    #     "kubernetes.io/role/internal-elb" = "1"
    # }
    # eks-autoscaler-tag = {
    #     "k8s.io/cluster-autoscaler/enabled"                = "true"
    #     format("k8s.io/cluster-autoscaler/%s", local.name) = "owned"
    # }
    # eks-tag = merge(
    #     {
    #       "eks:cluster-name" = local.name
    #     },
    #     local.eks-owned-tag,
    #     local.eks-autoscaler-tag,
    # )
}