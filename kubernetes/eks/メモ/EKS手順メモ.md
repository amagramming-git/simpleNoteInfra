# EKS手順メモ

## 下準備
AWSアカウントを作成する。  
IAMユーザー(Admin)を作成する。  
アクセスキー・シークレットアクセスキーを払い出す。  
絶対にGithubなどにアップロードしては行けない！！！！

プロファイルの切り替え
export AWS_PROFILE=eks-demo  
確認
aws sts get-caller-identity  

## EKSの作成
eksctl create cluster \
    --name eks-from-eksctl \
    --version 1.21 \
    --region ap-northeast-1 \
    --nodegroup-name workers \
    --node-type t3.small \
    --nodes 2 \
    --nodes-min 1 \
    --nodes-max 3 \
    --ssh-access \
    --ssh-public-key ~/.ssh/eks-demo.pem.pub \
    --managed

node-typeはもしかするとt3.mediumのほうがいいかも
ただ値段が高いからとりあえずビビってt3.smallにしておく。

作成されたかどうかを確認する。
aws eks describe-cluster --name eks-from-eksctl --region ap-northeast-1

kubectlで接続可能かどうかの確認
```bash
kubectl get svc
```

`kubernetes` service（マスターノードのAPI server）がデフォルトで作られているのがわかる
```bash
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.100.0.1   <none>        443/TCP   38m
```


nginx ingressを作成する。

準備
ローカルのhelmをアップデートしたりaddしたりする
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update


ネームスペースを作成してnginx ingressを作成する。
kubectl create namespace nginx-ingress-controller
helm install nginx-ingress-controller ingress-nginx/ingress-nginx -n nginx-ingress-controller 
参考https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx


DNSを設定する。
helm upgrade nginx-ingress-controller \
    ingress-nginx/ingress-nginx \
    -n nginx-ingress-controller \
    -f helm/ingress-nginx/nginx_helm_chart_overrides_https.yaml --install

マネージメントコンソールからRoute53でAレコードを手動で追加すると、DNSで接続することができるようになるよ

DB作成
```
kubectl apply -f manifesto/configmap.yaml
kubectl apply -f manifesto/db_deployment.yaml
kubectl apply -f manifesto/db_service.yaml
```

接続確認
```
kubectl run mysql-client --image=mysql:5.7 -it --rm --restart=Never -- /bin/bash
mysql -h db-clusterip -uroot -p -e 'SHOW databases;'
パスワードはconfigmapのMYSQL_ROOT_PASSWORD
exit
exitしても削除されない場合は kubectl delete pod mysql-client
```


kubectl apply -f manifesto/react_ingress.yaml
kubectl apply -f manifesto/django_ingress.yaml

nginxにて作成されたロードバランサーのURLを以下のファイルに記載する。
react_deployment.yaml
django_deployment.yaml
django_migratejob.yaml


マイグレーションの実行
```
kubectl apply -f manifesto/django_migratejob.yaml
```

次にdjangoの作成と接続確認
作成
```
kubectl apply -f manifesto/django_deployment.yaml
kubectl apply -f manifesto/django_service.yaml
```
接続確認
ブラウザから接続確認
http://ingressのADDRESSのIPアドレス/admin
画面が表示されればOK



次にreactの作成と接続確認
```
kubectl apply -f manifesto/react_deployment.yaml
kubectl apply -f manifesto/react_service.yaml
```



クリーンアップ
eksctl delete cluster --name eks-from-eksctl --region ap-northeast-1



 没helmでsimpleNoteを作成してみる←アプリ全体をHelmで管理すること自体にあまり魅力を感じなかった。
 誰かの作ったパッケージをインストールするのには積極的にhelmを使用したいが、
 独自で作成するアプリはむしろyamlで管理するほうがわかりやすいと思いました。





