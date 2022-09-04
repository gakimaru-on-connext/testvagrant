#!/bin/sh

echo Setup PostgreSQL

dnf provides postgresql-server

dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm

dnf -qy module disable postgresql

dnf -y install postgresql14-server

#dnf -y install postgresql14-docs
#dnf -y install postgresql14-devel
#dnf -y install postgresql14-libs postgresql14-plperl postgresql14-plpython3 postgresql14-pltcl postgresql14-tcl postgresql14-contrib postgresql14-llvmjit

/usr/pgsql-14/bin/postgresql-14-setup initdb

systemctl start postgresql-14
systemctl enable postgresql-14
systemctl status postgresql-14

# ToDo: 設定済み判定＆スキップ

#AdminDb=admin
sudo -i -u postgres psql <<EOD
CREATE DATABASE $AdminDb;
\l
EOD

AdminUser=admin
AdminPassword=hogehoge
sudo -i -u postgres psql <<EOD
CREATE ROLE $AdminUser WITH LOGIN SUPERUSER CREATEDB CREATEROLE PASSWORD '$AdminPassword';
\du
EOD

PG_HBA_PATH=/var/lib/pgsql/14/data/pg_hba.conf

sed -i "/host    all             all             127.0.0.1\/32            scram-sha-256/a host    all             all             192.168.56.0\/24         md5" $PG_HBA_PATH
#sed -i "/host    all             all             ::1\/128                 scram-sha-256/a host    all             all             192.168.56.0/24          md5" $PG_HBA_PATH

PG_CONF_PATH=/var/lib/pgsql/14/data/postgresql.conf 

sed -i "/#listen_addresses = 'localhost'/a listen_addresses = '*'" $PG_CONF_PATH

systemctl restart postgresql-14

firewall-cmd --add-port=5432/tcp --permanent
firewall-cmd --reload

# client(mac)
# $ brew install libpq
# $ echo 'export PATH=$PATH:/usr/local/opt/libpq/bin' >> ~/.zshrc
# $ psql -U admin -h 192.168.56.10 -d postgres
# $ psql 'postgres://admin:hogehoge@192.168.56.10:5432/postgres?sslmode=disable'
