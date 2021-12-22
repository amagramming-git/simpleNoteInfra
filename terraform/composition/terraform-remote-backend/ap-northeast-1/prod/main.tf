########################################
# AWS Terraform backend composition
########################################

module "terraform_remote_backend" {
  source   = "../../../../infrastructure_modules/terraform_remote_backend"
  env      = var.env
  app_name = var.app_name
  region   = var.region
  tags     = local.tags

  ########################################
  ## Terraform State S3 Bucket
  ########################################
  bucket_force_destroy = var.bucket_force_destroy

  ########################################
  ## DynamoDB
  ########################################
  dynamodb_hash_key   = var.dynamodb_hash_key
  dynamodb_attributes = var.dynamodb_attributes
}
