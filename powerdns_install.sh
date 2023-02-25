#!/bin/bash

# Install PowerDNS
apt-get update
apt-get install -y pdns-server pdns-backend-mysql

# Configure MySQL
echo "CREATE DATABASE powerdns;" | mysql -u root -p
echo "GRANT ALL ON powerdns.* TO 'powerdns'@'localhost' IDENTIFIED BY '$1';" | mysql -u root -p
echo "USE powerdns;" | mysql -u root -p
cat /usr/share/doc/pdns-backend-mysql/schema.mysql.sql | mysql -u root -p powerdns

# Update configuration files
sed -i "s/# launch+=gmysql/launch+=gmysql/" /etc/powerdns/pdns.conf
sed -i "s/# gmysql-host=localhost/gmysql-host=localhost/" /etc/powerdns/pdns.conf
sed -i "s/# gmysql-user=powerdns/gmysql-user=powerdns/" /etc/powerdns/pdns.conf
sed -i "s/# gmysql-password=password/gmysql-password=$1/" /etc/powerdns/pdns.conf
sed -i "s/# gmysql-dbname=powerdns/gmysql-dbname=powerdns/" /etc/powerdns/pdns.conf

# Restart PowerDNS
systemctl restart pdns.service

# Print MySQL root password
echo "PowerDNS installation complete! The MySQL root password is stored in a file called mysql-root-password.txt in the current directory."
