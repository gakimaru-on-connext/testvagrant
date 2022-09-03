#!/bin/sh

echo Setup MongoDB

MONGODB_VER=6.0

cp -f /vagrant/setup/config/etc/yum.repos.d/mongodb-org-6.0.repo /etc/yum.repos.d/.

dnf -y install mongodb-org
#dnf -y install mongodb-org-database mongodb-org-server mongodb-mongosh mongodb-org-mongos mongodb-org-tools

systemctl stop mongod

CONF_PATH=/etc/mongod.conf

sed -i -e "s,^  \(bindIp: 127.0.0.1\),  #\\1," $CONF_PATH
sed -i -e "/^  #bindIp: 127.0.0.1/a \  bindIp: ::,0.0.0.0" $CONF_PATH

systemctl start mongod
systemctl enable mongod
systemctl status mongod

firewall-cmd --add-port=27017/tcp --permanent
firewall-cmd --reload

# client(mac)
# $ brew install mongsh
# $ mongosh 192.168.56.10
