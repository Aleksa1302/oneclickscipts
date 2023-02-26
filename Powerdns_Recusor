#!/bin/bash

# Generate random passwords for MariaDB
MYSQL_ROOT_PASSWORD=$(openssl rand -hex 12)
MYSQL_PDNS_PASSWORD=$(openssl rand -hex 12)

# Install PowerDNS Recursor
apt-get update
apt-get install -y pdns-recursor

# Install MariaDB
apt-get install -y mariadb-server

# Secure MariaDB installation
mysql_secure_installation <<EOF
y
$MYSQL_ROOT_PASSWORD
$MYSQL_ROOT_PASSWORD
y
y
y
y
EOF

# Create PowerDNS database
mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE DATABASE powerdns;
GRANT ALL PRIVILEGES ON powerdns.* TO 'pdns'@'localhost' IDENTIFIED BY '$MYSQL_PDNS_PASSWORD';
FLUSH PRIVILEGES;
EOF

# Configure PowerDNS Recursor
cat <<EOF > /etc/powerdns/recursor.conf
allow-from=0.0.0.0/0
local-address=0.0.0.0
setgid=pdns-recursor
setuid=pdns-recursor
forward-zones=.=8.8.8.8,8.8.4.4
lua-dns-script=/etc/powerdns/lua-postfix.lua
EOF

# Create Lua script for Postfix integration
cat <<EOF > /etc/powerdns/lua-postfix.lua
function preresolve (remoteip, domain, qtype)
  if (qtype == pdns.A) and (domain == "example.com") then
    pdnslog("match postfix.example.com")
    return 0, {{qtype=pdns.A, content="1.2.3.4", ttl=60}}
  else
    return -1, {}
  end
end
EOF

# Restart PowerDNS Recursor
systemctl restart pdns-recursor

echo "PowerDNS Recursor and MariaDB installation and configuration complete."
echo "MariaDB root password: $MYSQL_ROOT_PASSWORD"
echo "PowerDNS database password: $MYSQL_PDNS_PASSWORD"
