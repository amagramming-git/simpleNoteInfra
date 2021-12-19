# backend
terraform {
  required_version = ">= 1.1.2"

  # backendはterraform{}ブロック内に定義される
  backend "s3" {
    bucket         = "terraform-backend-remote-state-965398552090"  #このS3 bucketが先に作られている必要がある （つまり、Terraform stateを保存するS3バケットはコンソールで作成するか、Local Terraform backendで作成）
    key            = "infra/ap-northeast-1/prod/terraform.tfstate" # .tfstateをS3 bucket内にObjectとして保存
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-backend-state-lock" # dynamoDBを使ってState Lockを有効化
    encrypt        = true
    profile        = "kambeAdmin"
  }
}