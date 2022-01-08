########################################
# Simple note infra
########################################

module "vpc" {
  source = "../../../../infrastructure_modules/vpc" # using infra module VPC which acts like a facade to many sub-resources
  ## Common tag metadata ##
  env      = var.env
  app_name = var.app_name
  tags     = local.tags
  region   = var.region

  ########################################
  # VPC
  ########################################
  cidr                 = var.cidr
  azs                  = var.azs
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  database_subnets     = var.database_subnets
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  # subnet tags for eks
  public_subnet_tags   = local.public_subnet_tags
  private_subnet_tags  = local.private_subnet_tags

  ########################################
  # Security Group
  ########################################
  ## Public Security Group ##

  ## Private Security Group ##

  ## Database security group ##
  create_eks                                                           = var.create_eks
  databse_computed_ingress_with_eks_worker_source_security_group_ids   = local.databse_computed_ingress_with_eks_worker_source_security_group_ids

}

module "eks" {
  source = "../../../../infrastructure_modules/eks"
  ## Common tag metadata ##
  env      = var.env
  app_name = var.app_name
  tags     = local.eks_tags
  region   = var.region

  ########################################
  ## EKS ##
  ########################################
  create_eks      = var.create_eks
  cluster_version = var.cluster_version
  cluster_name    = local.cluster_name
  vpc_id          = module.vpc.vpc_id
  subnets         = concat(module.vpc.public_subnets,module.vpc.private_subnets)
  fargate_subnets = module.vpc.private_subnets

  enable_irsa     = true
}

module "eks-lb-controller" {
  source = "../../../../infrastructure_modules/aws-load-balancer-controller"

  cluster_name    = local.cluster_name
  oidc_url        = module.eks.cluster_oidc_issuer_url
  oidc_arn        = module.eks.oidc_provider_arn
  aws_vpc_id      = module.vpc.vpc_id
  aws_region_name = var.region
  depends_on = [
    module.eks,
  ]
}