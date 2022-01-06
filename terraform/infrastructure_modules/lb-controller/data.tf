locals {
  name                          = join("-", compact([var.cluster_name, "aws-load-balancer-controller"]))
  oidc_fully_qualified_subjects = format("system:serviceaccount:%s:%s", var.helm_namespace, var.helm_serviceaccount)
  irsa_name                     = join("-", ["irsa", local.name])
  policy_arns                   = [aws_iam_policy.lbc.0.arn]
  default-tags                  = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
