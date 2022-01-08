
resource "aws_iam_policy" "lbc" {
  count       = var.enabled ? 1 : 0
  name        = local.name
  description = format("Allow aws-load-balancer-controller to manage AWS resources")
  path        = "/"
  policy      = file("${path.module}/policy.json")
}

# security/policy
resource "aws_iam_role" "irsa" {
  count = var.enabled ? 1 : 0
  name  = format("%s", local.irsa_name)
  path  = var.path
  tags  = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = var.oidc_arn
        }
        Condition = {
          StringEquals = {
            trimprefix(format("%s:aud", var.oidc_url),"https://") = "sts.amazonaws.com" 
            trimprefix(format("%s:sub", var.oidc_url),"https://") = local.oidc_fully_qualified_subjects
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each   = var.enabled ? { for key, val in local.policy_arns : key => val } : {}
  policy_arn = each.value
  role       = aws_iam_role.irsa[0].name
}

resource "kubernetes_service_account" "this" {
  automount_service_account_token = true
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = var.helm_namespace
    annotations = {
      # This annotation is only used when running on EKS which can
      # use IAM roles for service accounts.
      "eks.amazonaws.com/role-arn" = aws_iam_role.irsa[0].arn
    }
    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "using_iamserviceaccount" {
  count           = var.enabled ? 1 : 0

  name            = var.helm_name
  repository      = var.helm_repository
  chart           = var.helm_chart
  version         = var.helm_version
  namespace       = var.helm_namespace
  cleanup_on_fail = var.helm_cleanup_on_fail
  atomic          = true
  timeout         = 900
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "region"
    value = var.aws_region_name
  }
  set {
    name  = "vpcId"
    value = var.aws_vpc_id
  }
  depends_on = [
    kubernetes_service_account.this,
  ]
}
