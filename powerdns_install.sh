#!/bin/bash

# Generate random passwords for MySQL and PowerDNS users
MYSQL_PASSWORD=$(openssl rand -base64 32)
PDNS_PASSWORD=$(openssl rand -base64 32)

# Install PowerDNS and MySQL server
echo "Installing PowerDNS and MySQL server..."
sudo apt update
sudo apt install pdns-server pdns-backend-mysql mysql-server -y

# Create a MySQL database for PowerDNS
echo "Creating MySQL database..."
sudo mysql -e "CREATE DATABASE pdns;"
sudo mysql -e "CREATE USER 'pdns'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';"
sudo mysql -e "GRANT ALL PRIVILEGES ON pdns.* TO 'pdns'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Configure PowerDNS to use MySQL backend
echo "Configuring PowerDNS..."
sudo sed -i 's/^# launch=.*$/launch=gmysql/' /etc/powerdns/pdns.conf
sudo sed -i "s/^gmysql-host=.*$/gmysql-host=localhost/" /etc/powerdns/pdns.conf
sudo sed -i "s/^gmysql-user=.*$/gmysql-user=pdns/" /etc/powerdns/pdns.conf
sudo sed -i "s/^gmysql-password=.*$/gmysql-password=$PDNS_PASSWORD/" /etc/powerdns/pdns.conf
sudo sed -i "s/^gmysql-dbname=.*$/gmysql-dbname=pdns/" /etc/powerdns/pdns.conf
sudo sed -i 's/^# gmysql-dnssec=/gmysql-dnssec=yes/' /etc/powerdns/pdns.conf

# Create a new PowerDNS user for the web interface
echo "Creating PowerDNS user..."
sudo pdnsutil create-admin-user

#install pdns-recursor
sudo apt-get install pdns-recursor
systemctl disable systemd-resolved



# Restart PowerDNS server
echo "Restarting PowerDNS server..."
sudo systemctl restart pdns.service
sudo systemctl start pdns-recursor


# Print login information
echo "PowerDNS has been installed and configured."
echo "You can access the web interface at http://localhost:8081 using the following login credentials:"
echo "Username: admin"
echo "Password: (the password you set for the admin user)"
echo "The MySQL root password is: $MYSQL_PASSWORD"
echo "The PowerDNS user password is: $PDNS_PASSWORD"
