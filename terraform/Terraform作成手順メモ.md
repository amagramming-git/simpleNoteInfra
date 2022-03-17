# terraformを学習する際のメモ
主要コマンド
terraform init 
terraform init -backend-config=backend.config
terraform plan
terraform apply
terraform destroy

## terraform applyにて作成
まずはディレクトリを移動する。
cd terraform/composition/simple-note/ap-northeast-1/prod

terraform内のawsのprofileはご自身のものに書き換えてください。

まずはinit
terraform init 

※もしbackend-configの存在をご存知な人は任意のbackend-configの値に書き換えて実行してください。
詳しい説明は省略します。
terraform init -backend-config=backend.config

インフラエンジニアたるものplanで作成されるリソースは一通りちゃんと見よう！
まぁ勉強で作ってるだけだからあんまり確認しなくてもいいけど。
terraform plan

ではいよいよvpcやらeksやらを作成しましょう。
terraform apply
多分30分くらいはかかります。。。すごい時間かかる、、、。

## プロファイルの切り替え
awsのprofileはご自身のものに書き換えてください。
export AWS_PROFILE=kambeAdmin 

kubectlを実行できるようにconfigを設定しましょう。こういうのはgitでコミットしちゃだめです。
まぁaws profileないとログインできないけど、とはいえね、危ない。
export KUBECONFIG="${PWD}/kubeconfig_eks-tokyo-prod-simple-note"

## CoreDNS の更新
今回はfargateタイプのnodeのみ使用するため、CoreDNSを更新する必要があります。
参考 https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/fargate-getting-started.html

これはterraformで自動化したいですねー。まぁ他のアプリをmanifestで管理しているので、このコマンド一個実行するのはそんなに大変じゃないから
まぁ気にしなくてもいいんですけども。

kubectl patch deployment coredns \
    -n kube-system \
    --type json \
    -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'

## ServiceAccountを作成、aws-load-balancer-controllerを作成
terraformの以下のパスのリソースで作成するので、手動でのhelmチャートのinstallやserviceaccountの作成は不要です。
(大変だった、、)
terraform/infrastructure_modules/aws-load-balancer-controlle

## サンプルアプリの作成とクリーンアップ
awsの以下のサイトに記載されているサンプルアプリ「2048」を作成して正しく動作することを確認する。
https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/alb-ingress.html

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.0/docs/examples/2048/2048_full.yaml

kubectl get ingress/ingress-2048 -n game-2048
出力されたADDRESSのURLに接続して表示されることを確認する.
(アプリが起動するのに3〜10分くらい時間がかかることがあります。)

ゲームが表示されたらOK

クリーンアップ
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.0/docs/examples/2048/2048_full.yaml


## simple-noteアプリ作成
```
kubectl apply -f ../../../../../kubernetes/simpleNoteManifest/01_namespace.yaml \
&& kubectl apply -f ../../../../../kubernetes/simpleNoteManifest/02_ingress.yaml
```

以下のconfigmapの情報のうち、URLの部分を上書きしてからapplyする。
kubectl get ing -n simple-note
Addressの内容を03_configmap.yamlの該当箇所を更新
kubectl apply -f ../../../../../kubernetes/simpleNoteManifest/03_configmap.yaml

DB作成
```
kubectl apply -f ../../../../../kubernetes/simpleNoteManifest/04_01_db_deployment.yaml \
&& kubectl apply -f ../../../../../kubernetes/simpleNoteManifest/04_02_db_service.yaml
```
watch "kubectl get po -n simple-note"
DBの起動を待ってからマイグレーションの実行
```
kubectl apply -f ../../../../../kubernetes/simpleNoteManifest/05_django_migratejob.yaml
```
マイグレーションが完了するのを待ちます。STATUSがCompleteになるまで待ちます。
watch "kubectl get po -n simple-note"


次にdjangoとreactの作成と接続確認
作成
```
kubectl apply -f ../../../../../kubernetes/simpleNoteManifest/06_01_django_deployment.yaml\
&& kubectl apply -f ../../../../../kubernetes/simpleNoteManifest/06_02_django_service.yaml \
&& kubectl apply -f ../../../../../kubernetes/simpleNoteManifest/07_01_react_deployment.yaml \
&& kubectl apply -f ../../../../../kubernetes/simpleNoteManifest/07_02_react_service.yaml
```
watch "kubectl get po -n simple-note"
起動まで10分くらいはかかります。。気長に待ってください。。なんでこんな時間かかるんだろ。
モジュールのダウンロードに時間がかかってるんですが、、、

kubectl get ing -n simple-note
のaddressにアクセスしてアプリを開きます。

## クリーンアップ
ingressのリソースが残っていると、ALBが作成されっぱなしになってしまうので、terraformでvpcのリソースを削除できなくなります。
terraform destroyの前にkubectl deleteで削除しましょう。
もしterraform destroyがうまくいかなかったら、手動でマネージメントコンソールからalbを削除、vpcを削除してから再度実行するとうまくいくはずです。

```
kubectl delete -f ../../../../../kubernetes/simpleNoteManifest/02_ingress.yaml
terraform destroy
```


## 今後の展望
CoreDNS の更新とか、
kubernetesのリソースとかもterraform化するのも良い気がする。
でも多分現状(2021年12月時点)ではdeploymentがterraform対応していないので、
他のものをterraform化してもdeploymentが残ってしまうのはナンセンスなので、保留。
ただnamespaceとかingressとかconfigmapくらいはコード化してもいいかも。
https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace
https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress








## 参考
公式ドキュメント
https://registry.terraform.io/providers/hashicorp/aws/latest/docs
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
https://github.com/terraform-aws-modules

https://registry.terraform.io/modules/Young-ook/eks/aws/latest/examples/lb
https://github.com/Young-ook/terraform-aws-eks

ほか参考サイト
https://aws.amazon.com/jp/blogs/startup/techblog-container-k8s-1/
https://betterprogramming.pub/with-latest-updates-create-amazon-eks-fargate-cluster-and-managed-node-group-using-terraform-bc5cfefd5773

https://github.com/hashicorp/terraform-provider-kubernetes/issues/723





## 以下雑メモ

kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    --set clusterName=eks-tokyo-prod-simple-note \
    --set serviceAccount.create=false \
    --set region=ap-northeast-1 \
    --set vpcId=vpc-08f149c766d2ebc63 \
    --set serviceAccount.name=aws-load-balancer-controller \
    -n kube-system

watch "kubectl get deployment -n kube-system aws-load-balancer-controller"



kubectl cluster-info dump
helm uninstall aws-load-balancer-controller -n kube-system
kubectl delete -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"


eksctl delete iamserviceaccount --cluster eks-tokyo-prod-simple-note --namespace kube-system --name aws-load-balancer-controller




https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/ingress/annotations/
https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/ingress/cert_discovery/


