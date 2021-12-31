
## Metatada ##
variable "region" {
}

variable "env" {
}

variable "app_name" {
}

variable "tags" {
  type = map(string)
}
## EKS ## 
variable "create_eks" {}
variable "cluster_name" {}
variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

variable "vpc_id" {}
variable "subnets" {
  type = list(string)
}