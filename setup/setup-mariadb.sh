#!/bin/sh

echo Setup MariaDB

dnf -y install mariadb-server mariadb

systemctl start mariadb
systemctl enable mariadb
systemctl status mariadb

# ToDo: 設定済み判定＆スキップ

OldRootPasswd=
NewRootPasswd=hogehoge
expect -c '
    set timeout 10;
    spawn mysql_secure_installation;
    expect "Enter current password for root (enter for none):";
    send -- "'"${OldRootPasswd}"'\n";
    expect "Switch to unix_socket authentication";
    send "y\n";
    expect "Change the root password?";
    send "y\n";
    expect "New password:";
    send -- "'"${NewRootPasswd}"'\n";
    expect "Re-enter new password:";
    send -- "'"${NewRootPasswd}"'\n";
    expect "Remove anonymous users?";
    send "y\n";
    expect "Disallow root login remotely?";
    send "y\n";
    expect "Remove test database and access to it?";
    send "y\n";
    expect "Reload privilege tables now?";
    send "y\n";
    interact;'

#AdminDb=admin
#CREATE DATABASE $AdminDb;

AdminUser=admin
AdminPassword=hogehoge
MYSQL_PWD=$NewRootPasswd mysql -u root <<EOD
GRANT ALL PRIVILEGES ON *.* TO '$AdminUser'@'localhost' IDENTIFIED BY '$AdminPassword' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO '$AdminUser'@'127.0.0.1' IDENTIFIED BY '$AdminPassword' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO '$AdminUser'@'::1' IDENTIFIED BY '$AdminPassword' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO '$AdminUser'@'192.168.56.%' IDENTIFIED BY '$AdminPassword' WITH GRANT OPTION;
EOD

firewall-cmd --add-port=3306/tcp --permanent
firewall-cmd --reload

# client(mac)
# $ brew install mysql-client
# $ mysql -u admin -h 192.168.56.10 --password=hogehoge mysql
