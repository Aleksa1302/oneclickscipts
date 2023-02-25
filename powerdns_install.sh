#!/bin/bash

# Check if MySQL is installed
if ! command -v mysql &> /dev/null
then
    # Install MySQL
    echo "MySQL is not installed. Installing now..."
    sudo apt-get update
    sudo apt-get install -y mysql-server
fi

# Set MySQL root password
echo "Please enter a strong password for the MySQL root user:"
read -s sqlpassword

# Secure MySQL installation
sudo mysql_secure_installation <<EOF

y
$sqlpassword
$sqlpassword
y
y
y
y
EOF

# Create PowerDNS database and user
sudo mysql -u root -p$sqlpassword <<EOF
CREATE DATABASE powerdns;
CREATE USER 'powerdns'@'localhost' IDENTIFIED BY '$sqlpassword';
GRANT ALL PRIVILEGES ON powerdns.* TO 'powerdns'@'localhost';
FLUSH PRIVILEGES;
EOF

# Install PowerDNS
sudo apt-get update
sudo apt-get install -y pdns-server pdns-backend-mysql

# Configure PowerDNS to use MySQL
sudo sed -i 's/# launch=gmysql/launch=gmysql/' /etc/powerdns/pdns.conf
sudo sed -i 's|# gmysql-host=127.0.0.1|gmysql-host=localhost|' /etc/powerdns/pdns.conf
sudo sed -i 's/# gmysql-user=powerdns/gmysql-user=powerdns/' /etc/powerdns/pdns.conf
sudo sed -i "s/# gmysql-password=password/gmysql-password=$sqlpassword/" /etc/powerdns/pdns.conf

# Restart PowerDNS
sudo systemctl restart pdns.service

# Check for errors
if systemctl status pdns.service | grep -q 'failed'; then
    echo "There was an error starting PowerDNS. Please check the system logs for more information."
    exit 1
fi

echo "PowerDNS installation complete! The MySQL root password is stored in a file called mysql-root-password.txt in the current directory."
echo "The PowerDNS GUI is available at http://localhost:8081/ with username 'admin' and password '$sqlpassword'"
