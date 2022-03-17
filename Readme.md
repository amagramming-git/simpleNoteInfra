# 初めに
こちらのリポジトリをご閲覧いただきありがとうございます。  
当リポジトリはkanbassのインフラ学習用に  
DjangoとReact、MySQLのシンプルなノートアプリを  
AWS EKSのFargateタイプを使用して、circleCIでCICDパイプラインを作成し、  
terraformでIaCを実現しています。  

またYoutubeにて解説動画を投稿予定です。投稿しましたら、追記いたします。

## 使用技術一覧
* docker
* docker-compose
* kubernetes
* AWS
* EKS
* Fargate
* Django
* Python
* React
* Javascript
* terraform
* circleCI
* MySQL

## ディレクトリ構成
当アプリケーションは当リポジトリのみでは動作しません。  
同じディレクトリ内に以下の3つのリポジトリを取得して配置してください。  
* https://github.com/kanbass/simpleNoteInfra  
当リポジトリです。インフラにまつわるソースコードを格納しています。  
主にdocker-compose.yamlやkubernetesのyamlファイル、  
terraformの.tfファイルなどを格納しています。
* https://github.com/kanbass/simpleNoteDjango  
DjangoにてREST frameworkを使用してAPサーバーとして作成しています。
* https://github.com/kanbass/simpleNoteReact  
Reactにてフロントエンドの処理を実行します。  

## インフラ構成図

現在作成中です。  


## 環境構築
各環境を構築するにあたって必要になるファイルは以下の通り。  
* ローカル開発環境(docker-compose)  
docker-composeディレクトリを使用します。詳しい使い方はdocker-composeディレクトリ配下の手順メモをご確認ください。  

* ローカル開発環境(minikube)  
minikubeで使用可能なマニフェストファイルなどはkubernetes配下に格納予定です。  
現在VM Wareが最新のMacOSに非対応のため検証できておりません。  

* EKSonFargate環境(eksctlでの作成)  
kubernetesディレクトリ配下のファイルを使用します。詳しい使い方はkubernetesディレクトリ配下の手順メモをご確認ください。  

* EKSonFargate環境(terraformでの作成)  
kubernetesディレクトリ配下のファイル及びterraformディレクトリ配下のファイルを使用します。  
詳しい使い方はterraformディレクトリ配下の手順メモをご確認ください。  
