## 最低限必要なAWS Config (AWS CLIで”aws config”を実行して、Region、Access Keyなどを設定するのと同じ) ##
variable "aws_region" {
  default = "ap-northeast-1"
}
variable "aws_profile" {
  # type = string
  default = "kambeAdmin"
  # description = "AWS CLI's profile"
}
