<!-- omit in toc -->
# Vagrant Test

[https://github.com/gakimaru-on-connext/testvagrant](https://github.com/gakimaru-on-connext/testvagrant)

---
- [■概要](#概要)
- [■動作要件](#動作要件)
- [■VM 操作方法](#vm-操作方法)
- [■セットアップ内容](#セットアップ内容)
- [■各サーバーへのアクセス方法](#各サーバーへのアクセス方法)
- [■解説：Vagrant 設定](#解説vagrant-設定)
- [■解説：プロビジョニング](#解説プロビジョニング)
- [■ディレクトリ構成](#ディレクトリ構成)

---
## ■概要

- Vagrant を用いた VM 上へのOSセットアップのテスト
- シェル（スクリプト）によるセットアップを行う
- Ansible によるセットアップと比較するためのリポジトリも用意
  - [https://github.com/gakimaru-on-connext/testansible](https://github.com/gakimaru-on-connext/testansible)

---
## ■動作要件

- macOS ※x86系のみ

- Oracle Virtualbox

  - [https://www.oracle.com/jp/virtualization/technologies/vm/downloads/virtualbox-downloads.html](https://www.oracle.com/jp/virtualization/technologies/vm/downloads/virtualbox-downloads.html)

- Vagrant

  ```shell
  $ brew install vagrant
  ```

---
## ■VM 操作方法

<!-- omit in toc -->
### ▼VM 起動

```shell
$ cd vagrant
$ vagrant up
```

- ※初回の VM 起動時（VM生成時）には自動的にプロビジョニングも行われる

<!-- omit in toc -->
### ▼プロビジョニング（セットアップ）

```shell
$ cd vagrant
$ vagrant provision
```

- これにより、各セットアップシェルスクリプトが順次呼び出される

<!-- omit in toc -->
### ▼VM 再起動

```shell
$ cd vagrant
$ vagrant reload
```

<!-- omit in toc -->
### ▼VM 起動／再起動と同時にプロビジョニング

```shell
$ cd vagrant
$ vagrant up --provision
```

または

```shell
$ vagrant reload --provision
```

<!-- omit in toc -->
### ▼VM 起動時にプロビジョニングしない

```shell
$ cd vagrant
$ vagrant up --no-provision
```

<!-- omit in toc -->
### ▼全 VM の状態をリストアップ

```shell
$ vagrant global-status
id       name    provider   state    directory
------------------------------------------------------------------------------------------------
e4d2635  default  virtualbox running  /Users/user/works/testvagrant/vagrant
```

<!-- omit in toc -->
### ▼VM 停止

```shell
$ cd vagrant
$ vagrant halt
```

<!-- omit in toc -->
### ▼VM 破棄

```shell
$ cd vagrant
$ vagrant destroy
```

<!-- omit in toc -->
### ▼VM ログイン

```shell
$ cd vagrant
$ vagrant ssh
```

<!-- omit in toc -->
### ▼複数ホスト使用時の VM ログイン

```shell
$ cd vagrant
$ vagrant ssh (ホスト名)
```

- Vagrantfile で複数ホストを扱うように構成している場合、ログインの際には Vagrantfile でホスト名を指定する必要がある
  - 複数ホストを扱う時の Vagrantfile の例

    ```ruby
    # host01
    config.vm.define "host01" do |host01|
      host01.vm.box = "generic/rocky9"
      host01.vm.network "private_network", ip: "192.168.56.11"
      host01.vm.provider :virtualbox do |vb|
        vb.name = "testvagrant01"
      ...
    end

    # host02
    config.vm.define "host02" do |host02|
      host02.vm.box = "generic/rocky9"
      host02.vm.network "private_network", ip: "192.168.56.12"
      host02.vm.provider :virtualbox do |vb|
        vb.name = "testvagrant02"
      ...
    end
    ```

---
## ■セットアップ内容

<!-- omit in toc -->
### ▼OS

- Rocky Linux 9
  - RedHat 9 互換
  - CentOS 後継 OS の一つ

<!-- omit in toc -->
### ▼パッケージ

- MariaDB（MySQL互換のRDBサーバー）
- PostgreSQL（RDBサーバー）
- MongoDB（ドキュメントDBサーバー）
- Redis（キャッシュサーバー）
- Nginx（Webサーバー）
- Node.js（JavaScript開発・実行環境）

---
## ■各サーバーへのアクセス方法

- macOSからのアクセス方法

<!-- omit in toc -->
### ▼MariaDB

<!-- omit in toc -->
#### ▽準備

```shell
$ brew install mysql-client
```

<!-- omit in toc -->
#### ▽接続

```shell
$ mysql -u admin -h 192.168.56.10 --password=hogehoge mysql
mysql [admin@192.168.56.1 mysql] >
```

<!-- omit in toc -->
### ▼PostgreSQL

<!-- omit in toc -->
#### ▽準備

```shell
$ brew install libpq
$ echo 'export PATH=$PATH:/usr/local/opt/libpq/bin' >> ~/.zshrc
```

<!-- omit in toc -->
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

<!-- omit in toc -->
### ▼MongoDB

<!-- omit in toc -->
#### ▽準備

```shell
$ brew install mongsh
```

<!-- omit in toc -->
#### ▽接続

```shell
$ mongosh 192.168.56.10
test>
```

<!-- omit in toc -->
### ▼Redis

<!-- omit in toc -->
#### ▽準備

```shell
$ brew install redis
```

<!-- omit in toc -->
#### ▽接続

```shell
$ redis-cli -h 192.168.56.10
192.168.56.10:6379>
```

<!-- omit in toc -->
### ▼Nginx

<!-- omit in toc -->
#### ▽準備

```shell
$ brew install curl
```

<!-- omit in toc -->
#### ▽接続

```shell
$ curl http://192.168.56.10
...(HTML出力)...
```

- Webブラウザから http://192.168.56.10 にアクセスしても可

---
## ■解説：Vagrant 設定

<!-- omit in toc -->
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

<!-- omit in toc -->
### ▼Vagrant のネットワーク設定

- Vagrantfile

  ```ruby
  config.vm.network "private_network", ip: "192.168.56.10"
  ```

- 注）VirtualBox では、192.168.56.0/24 以外のアドレスを標準で許可していない
  - それ以外のアドレスを使用する場合は、/etc/vbox/networks.conf を設定する必要あり
    -  例）192.168.56.0/24 と 192.168.33.0/24 と 192.168.99.100/24 を許可する場合
      - /etc/vbox/networks.conf
        ```shell
        * 192.168.56.0/24 192.168.33.0/24 192.168.99.100/24
        ```
<!-- omit in toc -->
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

- これにより、例えば下記の２つのアクセス方法は同じ結果になる
   ```shell
   $ curl http://192.168.56.10
   ```
   ```shell
   $ curl http://127.0.0.1:40080
   ```

<!-- omit in toc -->
### ▼Vagrant のディレクトリ共有設定

- ホストOS側（macOS）とゲストOS側のディレクトリを共有する設定

<!-- omit in toc -->
#### ▽type: rsync

- Vagrantfile

  ```ruby
  config.vm.synced_folder "../setup/config", "/vagrant/setup/config", type: "rsync"
  ```

- 単方向共有（ホスト → ゲスト）
- 特徴：
  - VM 起動時やプロビジョニング時にのみ共有
    - （vagrant up / vagrant reload / vagrant provision 実行時）
  - vagrant rsync-auto を実行しておくと、ファイル更新の際に rsync が自動実行される

<!-- omit in toc -->
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

<!-- omit in toc -->
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

<!-- omit in toc -->
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

---
## ■解説：プロビジョニング

<!-- omit in toc -->
### ▼Vagrant プロビジョニング設定

- Vagrantfile

  ```ruby
  setup_dir = "../setup"
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup_os.sh", reboot: true
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup_package_mariadb.sh"
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup_package_postgresql.sh"
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup_package_mongodb.sh"
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup_package_redis.sh"
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup_package_nginx.sh"
  config.vm.provision :shell, privileged: true, path: setup_dir + "/setup_package_nodejs.sh"
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

```shell
testvagrant/
├── README.html
├── README.md
├── setup/                          # セットアップシェルスクリプト用
│   ├── config/                     # 各セットアップで使用する設定ファイル
│   │   └── etc/
│   │       └── yum.repos.d/
│   │           └── mongodb-org-6.0.repo
│   ├── setup_os.sh                 # OS のセットアップスクリプト
│   ├── setup_package_mariadb.sh    # MongoDB のセットアップスクリプト
│   ├── setup_package_mongodb.sh    # MongoDB のセットアップスクリプト
│   ├── setup_package_nginx.sh      # Nginx のセットアップスクリプト
│   ├── setup_package_nodejs.sh     # Node.js のセットアップスクリプト
│   ├── setup_package_postgresql.sh # PostgreSQL のセットアップスクリプト
│   └── setup_package_redis.sh      # Redis のセットアップスクリプト
└── vagrant/                        # vagrant 用
    ├── share/                      # vagrant 共有ディレクトリ
    └── Vagrantfile                 # vagrant VM 設定
```

----
以上
