locals {
  ########################################
  ## Util
  ########################################
  region_tag = {
    "ap-northeast-1" = "tokyo"
  }

  ########################################
  ## VPC ##  
  ########################################
  vpc_name = "vpc-${local.region_tag[var.region]}-${lower(var.app_name)}-${var.env}"

  create_database_subnet_group   = false
  manage_default_route_table     = false
  manage_default_security_group  = false

  enable_vpn_gateway             = false
  enable_dhcp_options            = false
  enable_classiclink             = false
  enable_classiclink_dns_support = false

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 600


  tags = merge(
           var.tags, 
           tomap({
               "VPC-Name" = local.vpc_name
           })
         )

  public_subnet_tags = merge(
                         var.public_subnet_tags, 
                         tomap({
                             "VPC-Name" = "public"
                         })
                       )

  private_subnet_tags = merge(
                         var.private_subnet_tags, 
                         tomap({
                             "VPC-Name" = "private"
                         })
                        )

  database_subnet_tags = {
    "Tier" = "database"
  }

  ########################################
  ## Public SG ##
  ########################################
  public_security_group_name        = "scg-${local.region_tag[var.region]}-${var.env}-public"
  public_security_group_description = "Security group for public subnets"
  public_security_group_tags = merge(
    var.tags,
    tomap({
        "Name" = local.public_security_group_name
    }),
    tomap({
        "Tier" = "public"
    })
  )


  ########################################
  ## Private SG ##
  ########################################
  private_security_group_name        = "scg-${local.region_tag[var.region]}-${var.env}-private"
  private_security_group_description = "Security group for private subnets"
  private_security_group_tags = merge(
    var.tags,
    tomap({
        "Name" = local.private_security_group_name
    }),
    tomap({
        "Tier" = "private"
    }),
  )

  private_security_group_number_of_computed_ingress_with_source_security_group_id = 2
  private_security_group_computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.public_security_group.security_group_id
      description              = "Port 80 from public SG rule"
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.public_security_group.security_group_id
      description              = "Port 443 from public SG rule"
    },
    # bastion EC2 not created yet 
    # {
    #   rule                     = "ssh-tcp"
    #   source_security_group_id = var.bastion_sg_id
    #   description              = "SSH from bastion SG rule"
    # },
  ]
  
  ########################################
  ## DB SG ##
  ########################################
  db_security_group_name        = "scg-${local.region_tag[var.region]}-${var.env}-database"
  db_security_group_description = "Security group for database subnets"
  db_security_group_tags = merge(
    var.tags,
    tomap({
        "Name" = local.db_security_group_name
    }),
    tomap({
        "Tier" = "database"
    }),
  )


  db_security_group_number_of_computed_ingress_with_source_security_group_id = var.create_eks ? 7 : 4
  db_security_group_computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mongodb-27017-tcp"
      source_security_group_id = module.private_security_group.security_group_id
      description              = "mongodb-27017 from private SG"
    },
    {
      rule                     = "mongodb-27018-tcp"
      source_security_group_id = module.private_security_group.security_group_id
      description              = "mongodb-27018 from private SG"
    },
    {
      rule                     = "mongodb-27019-tcp"
      source_security_group_id = module.private_security_group.security_group_id
      description              = "mongodb-27019 from private SG"
    },
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.private_security_group.security_group_id
      description              = "mysql-3306 from private SG"
    },
    # DB Controller EC2 not created yet
    # {
    #   rule                     = "mongodb-27017-tcp"
    #   source_security_group_id = var.databse_computed_ingress_with_db_controller_source_security_group_id
    #   description              = "mongodb-27017 from DB controller in private subnet"
    # },
    # {
    #   rule                     = "mongodb-27018-tcp"
    #   source_security_group_id = var.databse_computed_ingress_with_db_controller_source_security_group_id
    #   description              = "mongodb-27018 from DB controller in private subnet"
    # },
    # {
    #   rule                     = "mongodb-27019-tcp"
    #   source_security_group_id = var.databse_computed_ingress_with_db_controller_source_security_group_id
    #   description              = "mongodb-27019 from DB controller in private subnet"
    # },
    # {
    #   rule                     = "mysql-tcp"
    #   source_security_group_id = var.databse_computed_ingress_with_db_controller_source_security_group_id
    #   description              = "mysql-3306 from DB Controller SG"
    # },
    # EKS SG not created yet
    # {
    #   rule                     = "mysql-tcp"
    #   source_security_group_id = data.aws_security_group.eks_worker_sg.id
    #   description              = "mysql-3306 from private SG in peerwell-devops account"
    # },
  ]

}