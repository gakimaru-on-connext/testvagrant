#!/bin/sh

echo Setup Redis

dnf -y install redis

systemctl start redis
systemctl enable redis
systemctl status redis

REDIS_CONF_PATH=/etc/redis/redis.conf

sed -i 's/\(^bind 127.0.0.1 -::1\)/#\1/' $REDIS_CONF_PATH
sed -i "/^#bind 127.0.0.1 -::1/a bind * -::*" $REDIS_CONF_PATH

systemctl restart redis

firewall-cmd --add-port=6379/tcp --permanent
firewall-cmd --reload

# client(mac)
# $ brew install redis
# $ redis-cli -h 192.168.56.10
