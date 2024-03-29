########################################
# Metadata
########################################

variable "env" {
  description = "The name of the environment."
  type = string
}

variable "region" {
  type = string
}

variable "profile_name" {
  type = string
}

variable "app_name" {
  description = "The name of the application."
  type = string
}

########################################
# VPC
########################################

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  default     = "0.0.0.0/0"
}

variable "azs" {
  description = "Number of availability zones to use in the region"
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = []
}

variable "database_subnets" {
  description = "A list of database subnets inside the VPC"
  default     = []
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = true
}


########################################
# Security Group
########################################

## Public Security Group ##

## Private Security Group ##
# variable "bastion_sg_id" {
#   default = ""
# }

## Database security group ##
# variable "databse_computed_ingress_with_db_controller_source_security_group_id" {
#   default = ""
# }
variable "databse_computed_ingress_with_eks_worker_source_security_group_ids" {
  type = list(object({
    rule                     = string
    source_security_group_id = string
    description              = string
  }))
  default = []
}

# variable "cluster_name" {}

########################################
## EKS ## 
########################################
variable "create_eks" {}
variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}
