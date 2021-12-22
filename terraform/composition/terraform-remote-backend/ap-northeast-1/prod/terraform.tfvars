########################################
# Environment setting
########################################
region = "ap-northeast-1"
profile_name = "kambeAdmin"
env = "prod"
app_name = "simple-note"

########################################
## Terraform State S3 Bucket
########################################
bucket_force_destroy = false

########################################
## DynamoDB
########################################
dynamodb_hash_key = "LockID"
dynamodb_attributes = [
    {
        name = "LockID" 
        type = "S"
    },
]