# 初めに
こちらのリポジトリをご閲覧いただきありがとうございます。


## ディレクトリ構成
simpleNoteというアプリケーションを作成するためのインフラにまつわるリソースを記載します。
必ず以下のような構成でGitリポジトリをダウンロードしてください。
├── simpleNoteDjango Gitのリポジトリをpullしてください。 配下に.envファイルを配置してください。  
│     └── .env 
├── simpleNoteReact Gitのリポジトリをpullしてください。 配下に.envファイルを配置してください。  
│     └── .env 
├── simpleNoteMySQL フォルダを作成して、配下に.envファイルを配置してください。
│     └── .env 
└── simpleNoteInfra このGitリポジトリです。

## 環境構築
各環境を構築するにあたって必要になるファイルは以下の通り。
・ローカル開発環境(docker-compose)
docker-composeディレクトリを使用します。詳しい使い方はdocker-composeディレクトリ配下の手順メモをご確認ください。

・ローカル開発環境(minikube)
minikubeで使用可能なマニフェストファイルなどはkubernetes配下に格納予定です。
現在VM Wareが最新のMacOSに非対応のため検証できておりません。

・EKSonFargate環境(eksctlでの作成)
kubernetesディレクトリ配下のファイルを使用します。詳しい使い方はkubernetesディレクトリ配下の手順メモをご確認ください。

・EKSonFargate環境(terraformでの作成)
現在作成中です。
kubernetesディレクトリ配下のファイル及びterraformディレクトリ配下のファイルを使用します。
詳しい使い方はterraformディレクトリ配下の手順メモをご確認ください。
