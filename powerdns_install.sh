#!/bin/bash

# Generate a strong password for the MySQL user
MYSQL_PASSWORD=$(openssl rand -base64 32)

# Update the system packages
sudo apt-get update

# Install PowerDNS and MySQL server
sudo apt-get install pdns-server pdns-backend-mysql mysql-server -y

# Create a new database for PowerDNS
mysql -u root -p -e "CREATE DATABASE pdns;"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON pdns.* TO 'pdns'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';"

# Create the PowerDNS database schema
sudo pdnsutil create-db mysql

# Update the PowerDNS configuration file
sudo sed -i 's/^launch=.*/launch=gmysql/' /etc/powerdns/pdns.conf
sudo sed -i 's/^gmysql-host=.*/gmysql-host=127.0.0.1/' /etc/powerdns/pdns.conf
sudo sed -i 's/^gmysql-user=.*/gmysql-user=pdns/' /etc/powerdns/pdns.conf
sudo sed -i "s/^gmysql-password=.*/gmysql-password=$MYSQL_PASSWORD/" /etc/powerdns/pdns.conf

# Restart the PowerDNS service
sudo systemctl restart pdns

# Open port 53 and 3306 in the firewall
sudo ufw allow 53/tcp
sudo ufw allow 3306/tcp
sudo ufw reload

# Display the PowerDNS version and status
sudo pdns_control version
sudo pdns_control status

# Print the MySQL password
echo "MySQL password: $MYSQL_PASSWORD"
