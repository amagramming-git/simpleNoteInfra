resource "aws_iam_policy" "s3_full_access" {
  name        = "s3_full_access"
  path        = "/"
  description = "s3_full_access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
