# EKSonFargate手順メモ

## 下準備
AWSアカウントを作成する。  
IAMユーザー(Admin)を作成する。  
アクセスキー・シークレットアクセスキーを払い出す。  
絶対にGithubなどにアップロードしてはいけない！！！！

プロファイルの切り替え
export AWS_PROFILE=kambeAdmin 
確認
aws sts get-caller-identity  

## ECRにimageをpushする。

terraformかマネジメントコンソールなどでECRのリポジトリを作成する。

【参考】
もしaws cli で作成する場合は以下のコマンドを実施
aws ecr create-repository --repository-name ${REPOSITORY_NAME} --region ${AWS_REGION}
aws ecr describe-repositories --region ${AWS_REGION}

dockerでecrのリポジトリにログインする
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin 965398552090.dkr.ecr.ap-northeast-1.amazonaws.com

dockerFileのあるディレクトリで以下のようにコマンドを実行してイメージを作成する。
docker build -t ${REPOSITORY_NAME} .
docker tag ${REPOSITORY_NAME}:latest 965398552090.dkr.ecr.ap-northeast-1.amazonaws.com/${REPOSITORY_NAME}:v1.0
docker push 965398552090.dkr.ecr.ap-northeast-1.amazonaws.com/${REPOSITORY_NAME}:v1.0

## EKSの作成

eksctl create cluster \
  --name eks-from-eksctl \
  --version 1.21 \
  --fargate

おおよそ20分くらいかかります、、、

## aws-load-balancer-controllerの作成

基本的に公式ドキュメントに記載されています。
公式ドキュメント通りAWSLoadBalancerControllerIAMPolicyを作成した後に以下のコマンドを実行します。

eksctl utils associate-iam-oidc-provider --cluster eks-from-eksctl --approve

iamロールのARNだけ自身のものに置き換えてください。
eksctl create iamserviceaccount \
  --cluster=eks-from-eksctl \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::965398552090:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

kubectl describe serviceaccount aws-load-balancer-controller --namespace kube-system

kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

vpcidのみ自身のものに置き換えてください。
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    --set clusterName=eks-from-eksctl \
    --set serviceAccount.create=false \
    --set region=ap-northeast-1 \
    --set vpcId=vpc-01263d565b6f33654  \
    --set serviceAccount.name=aws-load-balancer-controller \
    -n kube-system

kubectl get deployment -n kube-system aws-load-balancer-controller

## シンプルノートの作成

eksctl create fargateprofile  \
    --cluster eks-from-eksctl  \
    --region ap-northeast-1  \
    --name simple-note-profile  \
    --namespace simple-note


kubectl apply -f kubernetes/simpleNoteManifest/01_namespace.yaml
kubectl apply -f kubernetes/simpleNoteManifest/02_ingress.yaml


以下のconfigmapの情報を上書きして作成する。
kubectl get ing -n simple-note
kubectl apply -f kubernetes/simpleNoteManifest/03_configmap.yaml

DB作成
```
kubectl apply -f kubernetes/simpleNoteManifest/04_01_db_deployment.yaml \
&& kubectl apply -f kubernetes/simpleNoteManifest/04_02_db_service.yaml
```
watch "kubectl get po -n simple-note"
DBの起動を待ってからマイグレーションの実行
```
kubectl apply -f kubernetes/simpleNoteManifest/05_django_migratejob.yaml
```

次にdjangoとreactの作成と接続確認
作成
```
kubectl apply -f kubernetes/simpleNoteManifest/06_01_django_deployment.yaml\
&& kubectl apply -f kubernetes/simpleNoteManifest/06_02_django_service.yaml \
&& kubectl apply -f kubernetes/simpleNoteManifest/07_01_react_deployment.yaml \
&& kubectl apply -f kubernetes/simpleNoteManifest/07_02_react_service.yaml
```

## クリーンアップ
helm uninstall aws-load-balancer-controller -n kube-system
kubectl delete -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

eksctl delete cluster --name eks-from-eksctl --region ap-northeast-1