variable "cluster_name" {
  description = "The kubernetes cluster name"
  type        = string
}

variable "enabled" {
  description = "A conditional indicator to enable cluster-autoscale"
  type        = bool
  default     = true
}

variable "oidc_url" {
  description = "A URL of the OIDC Provider"
  type        = string
}

variable "oidc_arn" {
  description = "An ARN of the OIDC Provider"
  type        = string
}

variable "path" {
  description = "The path for role"
  type        = string
  default     = "/"
}

variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}

variable "helm_namespace" {
  description = "The helm release configuration."
  type        = string
  default     = "kube-system"
}

variable "helm_serviceaccount" {
  description = "The helm release configuration."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "helm_repository" {
  description = "The helm release configuration."
  type        = string
  default     = "https://aws.github.io/eks-charts"
}

variable "helm_name" {
  description = "The helm release configuration."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "helm_chart" {
  description = "The helm release configuration."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "helm_cleanup_on_fail" {
  description = "The helm release configuration."
  type        = bool
  default     = true
}
variable "helm_version" {
  description = "The helm release configuration."
  type        = string
  default     = null
}

variable "aws_vpc_id" {
  description = "ID of the Virtual Private Network to utilize. Can be ommited if targeting EKS."
  type        = string
  default     = null
}

variable "aws_region_name" {
  description = "ID of the Virtual Private Network to utilize. Can be ommited if targeting EKS."
  type        = string
  default     = null
}