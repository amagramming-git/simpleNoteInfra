########################################
## S3Bucket 
########################################
module "s3_bucket_terraform_remote_backend" {
  source = "../../resource_modules/storage/s3"

  bucket        = local.bucket_name
  acl           = local.bucket_acl
  force_destroy = var.bucket_force_destroy

  attach_policy = local.bucket_attach_policy
  policy        = local.bucket_policy
  tags          = local.bucket_tags

  versioning     = local.bucket_versioning
  website        = local.bucket_website
  logging        = local.bucket_logging
  cors_rule      = local.bucket_cors_rule
  lifecycle_rule = local.bucket_lifecycle_rule

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = module.s3_kms_key_terraform_backend.arn # use custom KMS key created in a separate module
      }
    }
  }

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = local.bucket_block_public_acls
  block_public_policy     = local.bucket_block_public_policy
  ignore_public_acls      = local.bucket_ignore_public_acls
  restrict_public_buckets = local.bucket_restrict_public_buckets
}

########################################
## KMS
########################################
module "s3_kms_key_terraform_backend" {
  source = "../../resource_modules/identity/kms_key"

  name                               = local.kms_name
  description                        = local.kms_description
  policy                             = local.kms_policy
  deletion_window_in_days            = local.kms_deletion_window_in_days
  enable_key_rotation                = local.kms_enable_key_rotation
  multi_region                       = local.kms_multi_region
  tags                               = local.kms_tags
}

########################################
## Dynamodb for TF state locking
########################################
module "dynamodb_terraform_state_lock" {
  source         = "../../resource_modules/database/dynamodb"

  name      = local.dynamodb_name
  hash_key  = var.dynamodb_hash_key
  range_key = local.dynamodb_range_key

  attributes               = var.dynamodb_attributes
  global_secondary_indexes = local.dynamodb_global_secondary_indexes
  tags                     = local.dynamodb_tags
}