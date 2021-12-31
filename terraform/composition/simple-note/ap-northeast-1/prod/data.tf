locals {
  tags = {
    Environment = var.env
    Application = var.app_name
    Terraform   = true
  }
  ########################################
  ## VPC ##
  ########################################
  # EKS module not created yet, so assign empty list
  # databse_computed_ingress_with_eks_worker_source_security_group_ids = []
  # add three ingress rules from EKS worker SG to DB SG only when creating EKS cluster
  databse_computed_ingress_with_eks_worker_source_security_group_ids = var.create_eks ? [
    {
      rule                     = "mongodb-27017-tcp"
      source_security_group_id = module.eks.worker_security_group_id
      description              = "mongodb-27017 from EKS SG in private subnet"
    },
    {
      rule                     = "mongodb-27018-tcp"
      source_security_group_id = module.eks.worker_security_group_id
      description              = "mongodb-27018 from EKS SG in private subnet"

    },
    {
      rule                     = "mongodb-27019-tcp"
      source_security_group_id = module.eks.worker_security_group_id
      description              = "mongodb-27019 from EKS SG in private subnet"
    }
  ] : []


  ########################################
  # Subnet for EKS 
  ########################################
  # need to tag subnets with "shared" so K8s can find right subnets to create ELBs
  # https://aws.amazon.com/jp/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }
  # need tag for internal-elb to be able to create ELB
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                    = 1
  }

  ########################################
  # EKS
  ########################################
  region_tag = {
    "ap-northeast-1" = "tokyo"
  }

  cluster_name = "eks-${local.region_tag[var.region]}-${var.env}-${var.app_name}"
  eks_tags = {
    Environment = var.env
    Application = var.app_name
  }

}
# if you leave default value of "manage_aws_auth = true" then you need to configure the kubernetes provider as per the doc: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v12.1.0/README.md#conditional-creation, https://github.com/terraform-aws-modules/terraform-aws-eks/issues/911
data "aws_eks_cluster" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = module.eks.cluster_id
}