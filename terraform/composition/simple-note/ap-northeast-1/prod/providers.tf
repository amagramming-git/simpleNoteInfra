########################################
# Provider to connect to AWS
#
# https://www.terraform.io/docs/providers/aws/
########################################

terraform {
  required_version = ">= 1.1.2"
  backend "s3" {} # use backend.config for remote backend
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  # backend "s3" {} # use local backend to first create S3 bucket to store .tfstate later
}

provider "aws" {
  region  = var.region
  profile = var.profile_name
}
