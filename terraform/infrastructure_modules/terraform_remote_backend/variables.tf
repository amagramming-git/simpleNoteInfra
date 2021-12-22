########################################
# Metadata
########################################
variable "env" {
  description = "The name of the environment."
  type = string
}

variable "app_name" {
  description = "The name of the application."
  type = string
}

variable "region" {
  description = "The AWS region this bucket should reside in."
  type = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type = map
}


########################################
## S3
########################################
variable "bucket_force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

########################################
## DynamoDB
########################################
variable "dynamodb_hash_key" {
  description = "The attribute to use as the hash (partition) key."
  type = string
}

variable "dynamodb_attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data"
  type        = list(map(string))
  default     = []
}

