#!/bin/bash

# Check if script is being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Install PowerDNS and MySQL
echo "Installing PowerDNS and MySQL..."
apt-get update
apt-get install -y pdns-server pdns-backend-mysql mysql-server

# Prompt user for MySQL root password
echo "Please enter the MySQL root password:"
read -s MYSQL_ROOT_PASSWORD

# Update PowerDNS configuration file
echo "Updating PowerDNS configuration file..."
sed -i "s/^# launch=/launch=/" /etc/powerdns/pdns.conf
sed -i "s/^# gmysql-host=/gmysql-host=/" /etc/powerdns/pdns.conf
sed -i "s/^# gmysql-port=/gmysql-port=/" /etc/powerdns/pdns.conf
sed -i "s/^# gmysql-dbname=/gmysql-dbname=/" /etc/powerdns/pdns.conf
sed -i "s/^# gmysql-user=/gmysql-user=/" /etc/powerdns/pdns.conf
sed -i "s/^# gmysql-password=/gmysql-password=/" /etc/powerdns/pdns.conf
echo "gmysql-host=localhost" >> /etc/powerdns/pdns.conf
echo "gmysql-port=3306" >> /etc/powerdns/pdns.conf
echo "gmysql-dbname=pdns" >> /etc/powerdns/pdns.conf
echo "gmysql-user=pdns" >> /etc/powerdns/pdns.conf
echo "gmysql-password=$MYSQL_ROOT_PASSWORD" >> /etc/powerdns/pdns.conf

# Create PowerDNS database and user
echo "Creating PowerDNS database and user..."
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE pdns;"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON pdns.* TO 'pdns'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"

# Restart PowerDNS
echo "Restarting PowerDNS..."
systemctl restart pdns

# Print success message
echo "PowerDNS installation complete! The MySQL root password is stored in a file called mysql-root-password.txt in the current directory."
echo $MYSQL_ROOT_PASSWORD > mysql-root-password.txt
chmod 600 mysql-root-password.txt
