#!/bin/bash

# Install PowerDNS
echo "Installing PowerDNS..."
apt-get update
apt-get -y install pdns-server pdns-backend-mysql

# Generate a strong password
password=$(openssl rand -base64 12)
echo "The MySQL root password is: $password"
echo $password > mysql-root-password.txt

# Update the MySQL root password in the pdns configuration file
echo "Updating pdns configuration file..."
sed -i "s/^gmysql-password=.*$/gmysql-password=$password/" /etc/powerdns/pdns.d/pdns.local.gmysql.conf

# Update the MySQL root password in the pdns database
echo "Updating MySQL root password..."
mysql -u root -p"$password" -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$password';"

# Restart PowerDNS
echo "Restarting PowerDNS..."
systemctl restart pdns.service

echo "PowerDNS installation complete! The MySQL root password is stored in a file called mysql-root-password.txt in the current directory."
