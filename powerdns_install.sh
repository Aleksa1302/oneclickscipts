#!/bin/bash

# Generate random strings for database credentials
DB_NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
DB_USER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
DB_PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1)

# Install Ubuntu Server
sudo apt-get update
sudo apt-get install -y ubuntu-server

# Install MySQL
sudo apt-get install -y mysql-server

# Configure MySQL
sudo mysql -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"

# Install PowerDNS and MySQL backend
sudo apt-get install -y pdns-server pdns-backend-mysql

# Configure PowerDNS
sudo cat << EOF > /etc/powerdns/pdns.d/pdns.local.gmysql.conf
launch=gmysql
gmysql-host=localhost
gmysql-dbname=${DB_NAME}
gmysql-user=${DB_USER}
gmysql-password=${DB_PASS}
gmysql-dnssec=yes
EOF

# Restart PowerDNS
sudo systemctl restart pdns

# Save passwords to a file
sudo echo "Database Name: ${DB_NAME}" > pdns_passwords.txt
sudo echo "Database User: ${DB_USER}" >> pdns_passwords.txt
sudo echo "Database Password: ${DB_PASS}" >> pdns_passwords.txt

# Secure the password file
sudo chmod 600 pdns_passwords.txt
sudo chown root:root pdns_passwords.txt

# Print a message to the user
echo "PowerDNS has been installed and configured. Passwords have been saved to pdns_passwords.txt."
