########################################
# Environment setting
########################################
region = "ap-northeast-1"
profile_name = "kambeAdmin"
env = "prod"
app_name = "simple-note"

########################################
# VPC
########################################
cidr                  = "10.1.0.0/16" 
azs                   = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
public_subnets        = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"] # 256 IPs per subnet
private_subnets       = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
database_subnets      = ["10.1.105.0/24", "10.1.106.0/24", "10.1.107.0/24"]
enable_dns_hostnames  = "true"
enable_dns_support    = "true"
enable_nat_gateway    = "true" # need internet connection for worker nodes in private subnets to be able to join the cluster 
single_nat_gateway    = "true"


########################################
# EKS
########################################
create_eks = true
cluster_version = 1.21
