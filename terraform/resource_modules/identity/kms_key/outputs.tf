## kms_key ##
output "arn" {
    description = "The Amazon Resource Name (ARN) of the key."
    value = aws_kms_key.this.arn
}
output "key_id" {
    description = "The globally unique identifier for the key."
    value = aws_kms_key.this.key_id
}
output "tags_all" {
    description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
    value = aws_kms_key.this.tags_all
}


## aws_kms_key ##
output "alias_arn" {
    description = "The Amazon Resource Name (ARN) of the key alias."
    value = aws_kms_alias.this.arn
}
output "target_key_arn" {
    description = "The Amazon Resource Name (ARN) of the target key identifier."
    value = aws_kms_alias.this.target_key_arn
}