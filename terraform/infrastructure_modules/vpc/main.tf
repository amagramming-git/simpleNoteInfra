################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../../resource_modules/network/vpc"

  name = local.vpc_name
  cidr = var.cidr

  azs                 = var.azs
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  database_subnets    = var.database_subnets
  elasticache_subnets = []
  redshift_subnets    = []
  intra_subnets       = []

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  create_database_subnet_group   = local.create_database_subnet_group
  manage_default_route_table     = local.manage_default_route_table
  manage_default_security_group  = local.manage_default_security_group

  enable_vpn_gateway             = local.enable_vpn_gateway
  enable_dhcp_options            = local.enable_dhcp_options
  enable_classiclink             = local.enable_classiclink
  enable_classiclink_dns_support = local.enable_classiclink_dns_support

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = local.enable_flow_log
  create_flow_log_cloudwatch_log_group = local.create_flow_log_cloudwatch_log_group
  create_flow_log_cloudwatch_iam_role  = local.create_flow_log_cloudwatch_iam_role
  flow_log_max_aggregation_interval    = local.flow_log_max_aggregation_interval

  tags = local.tags
  public_subnet_tags   = local.public_subnet_tags
  private_subnet_tags  = local.private_subnet_tags
  database_subnet_tags = local.database_subnet_tags
}


module "public_security_group" {
  source = "../../resource_modules/compute/security_group"

  vpc_id      = module.vpc.vpc_id

  name        = local.public_security_group_name
  description = local.public_security_group_description

  # ingress
  # allow http and https
  ingress_rules            = ["http-80-tcp", "https-443-tcp"] 
  ingress_cidr_blocks      = ["0.0.0.0/0"]
  
  # egress
  # allow all
  egress_rules = ["all-all"]
  tags         = local.public_security_group_tags
}


module "private_security_group" {
  source = "../../resource_modules/compute/security_group"
  
  vpc_id      = module.vpc.vpc_id

  name        = local.private_security_group_name
  description = local.private_security_group_description
  

  # ingress
  # define ingress source as computed security group IDs, not CIDR block
  # ref: https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/examples/complete/main.tf#L150
  number_of_computed_ingress_with_source_security_group_id = local.private_security_group_number_of_computed_ingress_with_source_security_group_id
  computed_ingress_with_source_security_group_id = local.private_security_group_computed_ingress_with_source_security_group_id
  
  # allow ingress from within (i.e. connecting from EC2 to other EC2 associated with the same private SG)
  ingress_with_self = [
    {
      rule        = "all-all"
      description = "Self"
    },
  ]
  
  # egress
  # allow all egress
  egress_rules = ["all-all"]
  tags         = local.private_security_group_tags
}


module "database_security_group" {
  source = "../../resource_modules/compute/security_group"
  
  vpc_id      = module.vpc.vpc_id

  name        = local.db_security_group_name
  description = local.db_security_group_description
  
  # ingress
  # combine list of SG rules from EKS worker SG and private SG
  number_of_computed_ingress_with_source_security_group_id = local.db_security_group_number_of_computed_ingress_with_source_security_group_id
  computed_ingress_with_source_security_group_id           = concat(
    local.db_security_group_computed_ingress_with_source_security_group_id,
    var.databse_computed_ingress_with_eks_worker_source_security_group_ids
    )
  # Open for self (rule or from_port+to_port+protocol+description)
  ingress_with_self = [
    {
      rule        = "all-all"
      description = "Self"
    },
  ]
  
  # egress
  # allow all egress
  egress_rules = ["all-all"]
  tags         = local.db_security_group_tags
}