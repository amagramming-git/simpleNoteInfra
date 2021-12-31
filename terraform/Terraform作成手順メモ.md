terraformを学習する際のメモ

公式ドキュメント
https://registry.terraform.io/providers/hashicorp/aws/latest/docs
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
https://github.com/terraform-aws-modules

https://registry.terraform.io/modules/Young-ook/eks/aws/latest/examples/lb
https://github.com/Young-ook/terraform-aws-eks

参考
https://aws.amazon.com/jp/blogs/startup/techblog-container-k8s-1/
https://betterprogramming.pub/with-latest-updates-create-amazon-eks-fargate-cluster-and-managed-node-group-using-terraform-bc5cfefd5773

主要コマンド
terraform init 
terraform init -backend-config=backend.config
terraform plan
terraform apply
terraform destroy


export KUBECONFIG="${PWD}/kubeconfig_eks-apne1-prod-terraform-eks-demo-infra"





## terraform applyにて作成
terraform init -backend-config=backend.config
terraform plan
terraform apply

## ingressを作成
以下terraformで作成できるものもある。徐々にterraformに移行していく

プロファイルの切り替え
export AWS_PROFILE=kambeAdmin 
export KUBECONFIG="${PWD}/kubeconfig_eks-tokyo-prod-simple-note"


eksctl utils associate-iam-oidc-provider --cluster 	eks-tokyo-prod-simple-note --approve
eksctl create iamserviceaccount \
  --cluster=eks-tokyo-prod-simple-note \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::965398552090:policy/AwsLoadBalancerControllerForEksIamPolicy \
  --override-existing-serviceaccounts \
  --approve



kubectl get serviceaccount aws-load-balancer-controller --namespace kube-system
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    --set clusterName=eks-tokyo-prod-simple-note \
    --set serviceAccount.create=false \
    --set region=ap-northeast-1 \
    --set vpcId=vpc-002d885f912e7f7f1 \
    --set serviceAccount.name=aws-load-balancer-controller \
    -n kube-system

watch "kubectl get deployment -n kube-system aws-load-balancer-controller"


eksctl create fargateprofile  \
    --cluster eks-tokyo-prod-simple-note  \
    --region ap-northeast-1  \
    --name alb-sample-app-game-2048  \
    --namespace game-2048


helm uninstall aws-load-balancer-controller -n kube-system
eksctl delete iamserviceaccount --cluster eks-tokyo-prod-simple-note --namespace kube-system --name aws-load-balancer-controller
aws eks list-fargate-profiles --cluster-name eks-tokyo-prod-simple-note
aws eks delete-fargate-profile --fargate-profile-name fargate-profile-default --cluster-name eks-tokyo-prod-simple-note