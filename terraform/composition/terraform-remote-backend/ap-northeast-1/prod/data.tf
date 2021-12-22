########################################
# Data sources
########################################

# Computed variables
locals {
  tags = {
    Region      = var.region
    Application = var.app_name
  }
}

# Current cccount ID
data "aws_caller_identity" "current" {}
