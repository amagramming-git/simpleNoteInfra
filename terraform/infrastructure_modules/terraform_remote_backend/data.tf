########################################
# Data sources
########################################
# Current account ID
data "aws_caller_identity" "current" {}

# Computed variables
locals {
  ########################################
  ## Util
  ########################################
  region_tag = {
    "ap-northeast-1" = "tokyo"
  }

  ########################################
  ## Terraform State S3 Bucket
  ########################################
  bucket_name          = "s3-${local.region_tag[var.region]}-${lower(var.app_name)}-${var.env}-tf-backend-${data.aws_caller_identity.current.account_id}"
  bucket_acl           = "private"
  bucket_attach_policy = true
  bucket_policy        = data.aws_iam_policy_document.bucket_policy.json
  bucket_tags          = merge(
                           var.tags, 
                           tomap({
                               "Name" = local.bucket_name
                           })
                         )
  bucket_versioning    = {
    enabled = true
  }

  bucket_website        = {}
  bucket_logging        = {}
  bucket_cors_rule      = []
  bucket_lifecycle_rule = []

  # S3 bucket-level Public Access Block configuration
  bucket_block_public_acls       = true
  bucket_block_public_policy     = true
  bucket_ignore_public_acls      = true
  bucket_restrict_public_buckets = true


  ########################################
  ## KMS
  ########################################
  kms_name                    = "alias/cmk-s3-terraform-backend"
  kms_description             = "Kms key used for Terraform remote states stored in S3"
  kms_policy                  = data.aws_iam_policy_document.s3_terraform_states_kms_key_policy.json
  kms_deletion_window_in_days = "30"
  kms_enable_key_rotation     = true
  kms_multi_region            = false
  kms_tags                    = merge(
                                  var.tags,
                                  tomap({
                                      "Name" = local.kms_name
                                  })
                                )
  
  ########################################
  ## Dynamodb for TF state locking
  ########################################
  dynamodb_name                     = "dynamo-${local.region_tag[var.region]}-${lower(var.app_name)}-${var.env}-tf-state-lock"
  dynamodb_range_key                = null
  dynamodb_global_secondary_indexes = []
  dynamodb_tags                     = var.tags
}



# S3 Bucket Policy
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "${data.aws_caller_identity.current. arn}",
      ]
    }
    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "${data.aws_caller_identity.current. arn}",
      ]
    }
    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
  }
}

data "aws_iam_policy_document" "s3_terraform_states_kms_key_policy" {
  statement {
    sid = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
        type = "AWS"
        identifiers = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        ]
    }
    actions = [
      "kms:*",
    ]
    resources = ["*"]
  }
  statement {
    sid = "Allow access for Key Administrators"
    effect = "Allow"
    principals {
        type = "AWS"
        identifiers = [
          "${data.aws_caller_identity.current. arn}",
        ]
    }
    actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion",
        "kms:ReplicateKey",
        "kms:UpdatePrimaryRegion",
    ]
    resources = ["*"]
  }
  statement {
    sid = "Allow use of the key"
    effect = "Allow"
    principals {
        type = "AWS"
        identifiers = [
          "${data.aws_caller_identity.current. arn}",
        ]
    }
    actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
    ]
    resources = ["*"]
  }
  statement {
    sid = "Allow attachment of persistent resources"
    effect = "Allow"
    principals {
        type = "AWS"
        identifiers = [
          "${data.aws_caller_identity.current. arn}",
        ]
    }
    actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant",
    ]
    resources = ["*"]
    condition {
      test = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values = ["true"]
    }
  }
}