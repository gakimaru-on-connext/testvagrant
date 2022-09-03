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

- これにより、各セットアップシェルスクリプトが順次呼び出される

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
mysql [admin@192.168.56.1 mysql] >
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
Password for user admin: hogehoge（パスワード入力）
postgres=#
```
または
```shell
$ psql 'postgres://admin:hogehoge@192.168.56.10:5432/postgres?sslmode=disable'
postgres=#
```

### MongoDB

- 準備

```shell
$ brew install mongsh
```

- 接続

```shell
$ mongosh 192.168.56.10
test>
```

### Redis

- 準備

```shell
$ brew install redis
```

- 接続

```shell
$ redis-cli -h 192.168.56.10
192.168.56.10:6379>
```

### Nginx

- 準備

```shell
$ brew install curl
```

- 接続

```shell
$ curl http://192.168.56.10
...(HTML出力)...
```

## ディレクトリ構成

- vagrant/ ... vagrant 用
  - Vagrantfile ... vagrant VM 設定
- setup/ ... セットアップシェルスクリプト用
  - config/ ... 各セットアップで使用する設定ファイル
  - setup-os.sh ... OSのセットアップスクリプト
  - setup-mariadb.sh ... MariaDBのセットアップスクリプト
  - setup-postgresql.sh ... PostgreSQLのセットアップスクリプト
  - setup-mongodb.sh ... MongoDBのセットアップスクリプト
  - setup-redis.sh ... Redisのセットアップスクリプト
  - setup-nginx.sh ... Nginxのセットアップスクリプト
  - setup-nodejs.sh ... Node.jsのセットアップスクリプト

## 解説

- Vagrantfile 内の config.vm.box にて、VM の OS イメージを指定

  ```ruby
  config.vm.box = "generic/rocky9"
  ```

- Vagrantfile 内下部の config.vm.provision にて、シェルスクリプトによるプロビジョニングを指定

  ```ruby
  setup_dir = "../setup"
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup-os.sh", reboot: true
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup-mariadb.sh"
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup-postgresql.sh"
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup-mongodb.sh"
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup-redis.sh"
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup-nginx.sh"
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup-nodejs.sh"
  ```

  - 「privileged: true」の指定により、シェルスクリプトはスーパーユーザーで実行される
  - 下記のように「inline:」を使用すると、Vagrantfile に直接シェルスクリプトを埋め込むことも可能

    ```ruby
    config.vm.provision :shell, inline: <<-SHELL
    echo Foo!
    echo Bar!
    SHELL
    ```

----
以上
