# Vagrant Test

## ■リポジトリ

- [https://github.com/gakimaru-on-connext/testvagrant](https://github.com/gakimaru-on-connext/testvagrant)

---
## ■概要

- Vagrant を用いた VM 上へのOSセットアップのテスト
- シェルスクリプトによるセットアップを行う
- Ansible によるセットアップと比較できるように、同様の内容の Ansible 版も用意
  - [https://github.com/gakimaru-on-connext/testansible](https://github.com/gakimaru-on-connext/testansible)

---
## ■必要要件

- macOS ※x86系のみ
- 下記のインストールが行われていること
  - Oracle Virtualbox
      - [https://www.oracle.com/jp/virtualization/technologies/vm/downloads/virtualbox-downloads.html](https://www.oracle.com/jp/virtualization/technologies/vm/downloads/virtualbox-downloads.html)
  - Vagrant

    ```shell
    $ brew install vagrant
    ```

---
## ■VM 操作方法

### ▼VM 起動

```shell
$ cd vagrant
$ vagrant up
```

- ※初回の VM 起動時には自動的にプロビジョニングも行われる

### ▼プロビジョニング（セットアップ）

```shell
$ cd vagrant
$ vagrant provision
```

- これにより、各セットアップシェルスクリプトが順次呼び出される

### ▼VM 再起動

```shell
$ cd vagrant
$ vagrant reload
```

### ▼VM 起動／再起動と同時にプロビジョニング

```shell
$ cd vagrant
$ vagrant up --provision
$ vagrant reload --provision
```

### ▼VM 停止

```shell
$ cd vagrant
$ vagrant halt
```

### ▼VM 破棄

```shell
$ cd vagrant
$ vagrant destroy
```

---
## ■セットアップ内容

### ▼OS

- Rocky Linux 9
  - RedHat 9 互換
  - CentOS 後継 OS の一つ

### ▼パッケージ

- MariaDB（MySQL互換のRDBサーバー）
- PostgreSQL（RDBサーバー）
- MongoDB（ドキュメントDBサーバー）
- Redis（キャッシュサーバー）
- Nginx（Webサーバー）
- Node.js（JavaScript開発・実行環境）

---
## ■各サーバーへのアクセス方法（macOSからのアクセス）

### ▼MariaDB

#### ▽準備

```shell
$ brew install mysql-client
```

#### ▽接続

```shell
$ mysql -u admin -h 192.168.56.10 --password=hogehoge mysql
mysql [admin@192.168.56.1 mysql] >
```

### ▼PostgreSQL

#### ▽準備

```shell
$ brew install libpq
$ echo 'export PATH=$PATH:/usr/local/opt/libpq/bin' >> ~/.zshrc
```

#### ▽接続

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

### ▼MongoDB

#### ▽準備

```shell
$ brew install mongsh
```

#### ▽接続

```shell
$ mongosh 192.168.56.10
test>
```

### ▼Redis

#### ▽準備

```shell
$ brew install redis
```

#### ▽接続

```shell
$ redis-cli -h 192.168.56.10
192.168.56.10:6379>
```

### ▼Nginx

#### ▽準備

```shell
$ brew install curl
```

#### ▽接続

```shell
$ curl http://192.168.56.10
...(HTML出力)...
```

---
## ■解説

### ▼Vagrant の対象VMプラットフォームの指定

- Vagrantfile

  ```ruby
  config.vm.provider :virtualbox do |vb|
    vb.name = "testvagrant"
    vb.gui = false
    vb.memory = "2048"
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end
  ```

- VirtualBox を使用する場合は、provider に :virtualbox を指定
- VMWare を使用する場合は、provider に :vmware_desktop を指定
- Parallels （macOS）を使用する場合は、vagrant-parallels プラグインをインストールした上で、provider に :parallels を指定
  - vagrant-parallels プラグインのインストール
    - コマンドラインからインストールする場合
      ```shell
      $ vagrant plugin install vagrant-parallels
      ```
    - Vagrantfile でインストールを指定する場合
      ```ruby
      install_plugin('vagrant-parallels')
      ```
- Hyper-V （Windows）を使用する場合は、provider に :hyperv を指定

### ▼Vagrant のネットワーク設定

- Vagrantfile

  ```ruby
  config.vm.network "private_network", ip: "192.168.56.10"
  ```

### ▼Vagrant のポートフォワーディング設定

- ホストOS側（macOS）の特定のポートをゲストOS側にフォワードする設定

- Vagrantfile

  ```ruby
  config.vm.network "forwarded_port", guest: 80, host: 40080 # http
  config.vm.network "forwarded_port", guest: 443, host: 40443 # https
  config.vm.network "forwarded_port", guest: 6379, host: 46379, host_ip: "127.0.0.1", auto_correct: true # redis
  config.vm.network "forwarded_port", guest: 3306, host: 43306, host_ip: "127.0.0.1", auto_correct: true # mysql/mariadb
  config.vm.network "forwarded_port", guest: 5432, host: 45432, host_ip: "127.0.0.1", auto_correct: true # postgresql
  config.vm.network "forwarded_port", guest: 27017, host: 47017, host_ip: "127.0.0.1", auto_correct: true # mongdb
  ```

### ▼Vagrant のディレクトリ共有設定

- ホストOS側（macOS）とゲストOS側のディレクトリを共有する設定

#### ▽type: rsync

- Vagrantfile

  ```ruby
  config.vm.synced_folder "../setup/config", "/vagrant/setup/config", type: "rsync"
  ```

- 単方向共有（ホスト → ゲスト）
- 特徴：
  - VM 起動時にのみ共有

#### ▽type: virtualbox

- Vagrantfile

  ```ruby
  config.vm.synced_folder "./share", "/vagrant/share"
  ```

- 双方向共有（ホスト ←→ ゲスト）
- 特徴：
  - ホスト、ゲスト双方の書き込みが即座に他方に反映される
  - 設定が簡単だが、nfs と比較して遅い
  - type の指定を省略すると virtualbox になる（provider が VirtualBox の場合）

#### ▽type: nfs

- Vagrantfile

  ```ruby
  config.vm.synced_folder "/System/Volumes/Data" + File.expand_path("./share"), "/vagrant/share", type: "nfs", nfs_export: true, nfs_udp: false, nfs_version: 3
  ```

- 双方向共有（ホスト ←→ ゲスト）
- 特徴：
  - Mac/Linux 用
  - ホスト、ゲスト双方の書き込みが即座に他方に反映される
  - virtualbox 共有と比較して早い
  - ホスト側（macOS）で nfs サービスを予め起動しておく必要あり
  - VM 生成/破棄時に、ホスト側（macOS）で nfs の exports 設定が自動的に書き換えられる（macOS のセキュリティ設定も求められる）
    - /etc/exports
      ```shell
      # VAGRANT-BEGIN: 501 7fc60d2f-ccf8-4ccd-87e8-748ae8db3fce
      "/System/Volumes/Data/Users/itagaki/works/ox/test/testvagrant/vagrant/share" -alldirs -mapall=501:20 192.168.56.10
      # VAGRANT-END: 501 7fc60d2f-ccf8-4ccd-87e8-748ae8db3fce
      ```
  - ホストOS側のパスを /System/Volumes/ から始まるパスで指定する必要あり

#### ▽type: smb

- Vagrantfile

  ```ruby
  config.vm.synced_folder File.expand_path("./share"), "/vagrant/share", type: "smb"
  ```

- 双方向共有（ホスト ←→ ゲスト）
- 特徴：
  - Windows 用
  - ホスト、ゲスト双方の書き込みが即座に他方に反映される
  - virtualbox 共有と比較して早い

### ▼Vagrant プロビジョニング設定

- Vagrantfile

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
  - Vagrantfile
    ```ruby
    config.vm.provision "shell", inline: <<-SHELL
      echo Foo!
      echo Hoge!
    SHELL
    ```

---
## ■ディレクトリ構成

```
testvagrant/
├── README.html
├── README.md
├── setup/                   ... セットアップシェルスクリプト用
│   ├── config/              ... 各セットアップで使用する設定ファイル
│   │   └── etc/
│   │       └── yum.repos.d/
│   │           └── mongodb-org-6.0.repo
│   ├── setup-mariadb.sh     ... MongoDB のセットアップスクリプト
│   ├── setup-mongodb.sh     ... MongoDB のセットアップスクリプト
│   ├── setup-nginx.sh       ... Nginx のセットアップスクリプト
│   ├── setup-nodejs.sh      ... Node.js のセットアップスクリプト
│   ├── setup-os.sh          ... OS のセットアップスクリプト
│   ├── setup-postgresql.sh  ... PostgreSQL のセットアップスクリプト
│   └── setup-redis.sh       ... Redis のセットアップスクリプト
└── vagrant/                 ... vagrant 用
    ├── Vagrantfile          ... vagrant VM 設定
    └── share/               ... vagrant 共有ディレクトリ
```

----
以上
