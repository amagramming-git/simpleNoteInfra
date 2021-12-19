# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
data "aws_caller_identity" "current" {}

variable "s3_bucket_name" {
  default = "terraform-backend-remote-state"
}

# S3 bucket
resource "aws_s3_bucket" "terraform-backend-remote-state" {
  bucket = "${var.s3_bucket_name}-${data.aws_caller_identity.current.account_id}" # 注意： S3 bucketの名前はGlobalでユニークでないといけない為、randomな数字を付け足しています
  
  # lifecycle {
  #   prevent_destroy = true # terraform destroyによって削除されないよう設定
  # }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Environment = "prod"
    Terraform   = "true"
    Name        = var.s3_bucket_name
  }
}

# DynamoDB for state locking
# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
# ref: https://medium.com/faun/3-tier-architecture-with-terraform-and-aws-part-3-setting-up-backend-s3-and-dynamodb-cb4d55d45d98
resource "aws_dynamodb_table" "terraform-backend-state-lock" {
  name         = "terraform-backend-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID" #値はLockIDである必要がある ref: https://www.terraform.io/docs/language/settings/backends/s3.html#dynamodb-state-locking

  attribute {
    name = "LockID" #値はLockIDである必要がある ref: https://www.terraform.io/docs/language/settings/backends/s3.html#dynamodb-state-locking
    type = "S"
  }

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}

# local backend
terraform {
  required_version = ">= 1.1.2"

  # # backendはterraform{}ブロック内に定義される
  # backend "s3" {
  #   bucket         = "terraform-backend-remote-state-aws-demo-23"  #このS3 bucketが先に作られている必要がある （つまり、Terraform stateを保存するS3バケットはコンソールで作成するか、Local Terraform backendで作成）
  #   key            = "infra/ap-northeast-1/prod/terraform.tfstate" # .tfstateをS3 bucket内にObjectとして保存
  #   region         = "ap-northeast-1"
  #   dynamodb_table = "terraform-backend-state-lock" # dynamoDBを使ってState Lockを有効化
  #   encrypt        = true
  # }
}