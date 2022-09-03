#!/bin/sh

echo Setup NginX

dnf -y install nginx

systemctl start nginx
systemctl enable nginx
systemctl status nginx

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

# client(mac)
# $ brew install curl
# $ curl http://192.168.56.10
