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
    --nodes 1 \
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
    -f kubernetes/eks/helm/ingress-nginx/nginx_helm_chart_overrides_https.yaml --install

マネージメントコンソールからRoute53でAレコードを手動で追加すると、DNSで接続することができるようになるよ

DB作成
```
kubectl apply -f kubernetes/eks/manifesto/dockerhub/configmap.yaml
kubectl apply -f kubernetes/eks/manifesto/dockerhub/db_deployment.yaml
kubectl apply -f kubernetes/eks/manifesto/dockerhub/db_service.yaml
```

接続確認
```
kubectl run mysql-client --image=mysql:5.7 -it --rm --restart=Never -- /bin/bash
mysql -h db-clusterip -uroot -p -e 'SHOW databases;'
パスワードはconfigmapのMYSQL_ROOT_PASSWORD
exit
exitしても削除されない場合は kubectl delete pod mysql-client
```


kubectl apply -f kubernetes/eks/manifesto/dockerhub/react_ingress.yaml
kubectl apply -f kubernetes/eks/manifesto/dockerhub/django_ingress.yaml

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
kubectl apply -f kubernetes/eks/manifesto/dockerhub/django_deployment.yaml
kubectl apply -f kubernetes/eks/manifesto/dockerhub/django_service.yaml
```
接続確認
ブラウザから接続確認
http://ingressのADDRESSのIPアドレス/admin
画面が表示されればOK



次にreactの作成と接続確認
```
kubectl apply -f kubernetes/eks/manifesto/dockerhub/react_deployment.yaml
kubectl apply -f kubernetes/eks/manifesto/dockerhub/react_service.yaml
```



クリーンアップ
eksctl delete cluster --name eks-from-eksctl --region ap-northeast-1



没helmでsimpleNoteを作成してみる←アプリ全体をHelmで管理すること自体にあまり魅力を感じなかった。
誰かの作ったパッケージをインストールするのには積極的にhelmを使用したいが、
独自で作成するアプリはむしろyamlで管理するほうがわかりやすいと思いました。



## ECRにimageをpushする。またそれをEKSで取得してデプロイする。

まず変数宣言
AWS_REGION=ap-northeast-1
REPOSITORY_NAME=simple-note-react

リポジトリを作成する。
aws ecr create-repository --repository-name ${REPOSITORY_NAME} --region ${AWS_REGION}
aws ecr describe-repositories --region ${AWS_REGION}

dockerにログインする
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin 965398552090.dkr.ecr.ap-northeast-1.amazonaws.com

dockerFileのあるディレクトリで以下のようにコマンドを実行してイメージを作成する。
docker build -t simple-note-react .
docker tag simple-note-react:latest 965398552090.dkr.ecr.ap-northeast-1.amazonaws.com/simple-note-react:v1.0
docker push 965398552090.dkr.ecr.ap-northeast-1.amazonaws.com/simple-note-react:v1.0





AWS_REGION=ap-northeast-1
REPOSITORY_NAME=simple-note-django
aws ecr create-repository --repository-name ${REPOSITORY_NAME} --region ${AWS_REGION}
aws ecr describe-repositories --region ${AWS_REGION}

docker build -t simple-note-django .
docker tag simple-note-django:latest 965398552090.dkr.ecr.ap-northeast-1.amazonaws.com/simple-note-django:v1.0
docker push 965398552090.dkr.ecr.ap-northeast-1.amazonaws.com/simple-note-django:v1.0




## ECRのイメージを使用して環境構築

ネームスペースを作成してnginx ingressを作成する。
kubectl create namespace nginx-ingress-controller
helm install nginx-ingress-controller ingress-nginx/ingress-nginx -n nginx-ingress-controller 
参考https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx


DNSを設定する。
helm upgrade nginx-ingress-controller \
    ingress-nginx/ingress-nginx \
    -n nginx-ingress-controller \
    -f kubernetes/eks/helm/ingress-nginx/nginx_helm_chart_overrides_https.yaml --install

マネージメントコンソールからRoute53でAレコードを手動で追加すると、DNSで接続することができるようになるよ

DB作成
```
kubectl apply -f kubernetes/eks/manifesto/ecr/configmap.yaml
kubectl apply -f kubernetes/eks/manifesto/ecr/db_deployment.yaml
kubectl apply -f kubernetes/eks/manifesto/ecr/db_service.yaml
```

接続確認
```
kubectl run mysql-client --image=mysql:5.7 -it --rm --restart=Never -- /bin/bash
mysql -h db-clusterip -uroot -p -e 'SHOW databases;'
パスワードはconfigmapのMYSQL_ROOT_PASSWORD
exit
exitしても削除されない場合は kubectl delete pod mysql-client
```


kubectl apply -f kubernetes/eks/manifesto/ecr/react_ingress.yaml
kubectl apply -f kubernetes/eks/manifesto/ecr/django_ingress.yaml

nginxにて作成されたロードバランサーのURLを以下のファイルに記載する。
react_deployment.yaml
django_deployment.yaml
django_migratejob.yaml


マイグレーションの実行
```
kubectl apply -f kubernetes/eks/manifesto/ecr/django_migratejob.yaml
```

次にdjangoの作成と接続確認
作成
```
kubectl apply -f kubernetes/eks/manifesto/ecr/django_deployment.yaml
kubectl apply -f kubernetes/eks/manifesto/ecr/django_service.yaml
```
接続確認
ブラウザから接続確認
http://ingressのADDRESSのIPアドレス/admin
画面が表示されればOK



次にreactの作成と接続確認
```
kubectl apply -f kubernetes/eks/manifesto/ecr/react_deployment.yaml
kubectl apply -f kubernetes/eks/manifesto/ecr/react_service.yaml
```



クリーンアップ
eksctl delete cluster --name eks-from-eksctl --region ap-northeast-1

## GitにpushするたびにECRにイメージをpushする
https://nvie.com/posts/a-successful-git-branching-model/