
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
variable "create_eks" {
  description = "Controls if EKS resources should be created (it affects almost all resources)"
  type        = bool
  default     = true
}
variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
  default     = ""
}
variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}
variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
}
variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
  default     = []
}
variable "fargate_subnets" {
  description = "A list of subnets to place fargate workers within (if different from subnets)."
  type        = list(string)
  default     = []
}
variable "enable_irsa" {
  description = "Whether to create OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = false
}