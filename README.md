# Vagrant Test

## リポジトリ

- https://github.com/gakimaru-on-connext/testvagrant

## 概要

- Vagrant を用いた VM 上へのOSセットアップのテスト
- シェルスクリプトによるセットアップを行う

## 必要要件

- macOS ※x86系のみ
- 下記のインストールが行われていること
  - Oracle Virtualbox
      - https://www.oracle.com/jp/virtualization/technologies/vm/downloads/virtualbox-downloads.html
  - Vagrant
      ```shell
      $ brew install vagrant
      ```

## VM 操作方法

### VM 起動

```shell
$ cd vagrant
$ vagrant up
```

- ※初回の VM 起動時には自動的にプロビジョニングも行われる

### プロビジョニング（セットアップ）

```shell
$ cd vagrant
$ vagrant provision
```

### VM 再起動

```shell
$ cd vagrant
$ vagrant reload
```

### VM 起動／再起動と同時にプロビジョニング

```shell
$ cd vagrant
$ vagrant up --provision
$ vagrant reload --provision
```

### VM 停止

```shell
$ cd vagrant
$ vagrant halt
```

### VM 破棄

```shell
$ cd vagrant
$ vagrant destroy
```

## セットアップ内容

### OS

- Rocky Linux 9
  - RedHat 9 互換
  - CentOS 後継 OS の一つ

### パッケージ

- MariaDB（MySQL互換のRDBサーバー）
- PostgreSQL（RDBサーバー）
- MongoDB（ドキュメントDBサーバー）
- Redis（キャッシュサーバー）
- Nginx（Webサーバー）
- Node.js（JavaScript開発・実行環境）

## 各サーバーへのアクセス方法（macOSからのアクセス）

### MariaDB

- 準備

```shell
$ brew install mysql-client
```

- 接続

```shell
$ mysql -u admin -h 192.168.56.10 --password=hogehoge mysql
```

### PostgreSQL

- 準備

```shell
$ brew install libpq
$ echo 'export PATH=$PATH:/usr/local/opt/libpq/bin' >> ~/.zshrc
```

- 接続

```shell
$ psql -U admin -h 192.168.56.10 -d postgres
（パスワード入力）hogehoge
```
または
```shell
$ psql 'postgres://admin:hogehoge@192.168.56.10:5432/postgres?sslmode=disable'
```

### MongoDB

- 準備

```shell
$ brew install mongsh
```

- 接続

```shell
$ mongosh 192.168.56.10
```

### Redis

- 準備

```shell
$ brew install redis
```

- 接続

```shell
$ redis-cli -h 192.168.56.10
```

### Nginx

- 準備

```shell
$ brew install curl
```

- 接続

```shell
$ curl http://192.168.56.10
```

## ディレクトリ構成

- vagrant/ ... vagrant 用
  - Vagrantfile
- setup/  ... セットアップ用
  - config/ ... 各セットアップで使用する設定ファイル
  - setup-os.sh ... OSのセットアップ
  - setup-mariadb.sh ... MariaDBのセットアップ
  - setup-postgresql.sh ... PostgreSQLのセットアップ
  - setup-mongodb.sh ... MongoDBのセットアップ
  - setup-redis.sh ... Redisのセットアップ
  - setup-nginx.sh ... Nginxのセットアップ
  - setup-nodejs.sh ... Node.jsのセットアップ

----
以上
