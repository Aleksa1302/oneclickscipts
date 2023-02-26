#!/bin/bash

# Generate a random password for the Bind9 admin user
ADMIN_PASSWORD=$(openssl rand -base64 12)

# Generate a random password for the Bind9 rndc-key
RNDC_KEY=$(openssl rand -hex 16)

# Update the package index and install Bind9
sudo apt update
sudo apt install bind9 -y

# Backup the named.conf.options file
sudo cp /etc/bind/named.conf.options /etc/bind/named.conf.options.bak

# Configure the named.conf.options file with auto-generated passwords
sudo tee /etc/bind/named.conf.options > /dev/null <<EOF
options {
   directory "/var/cache/bind";
   recursion yes;
   allow-recursion { any; };
   forwarders {
      8.8.8.8;
      8.8.4.4;
   };

   # Auto-generated password for the Bind9 admin user
   # Password: $ADMIN_PASSWORD
   // replace "CHANGEME" with the hashed password
   # Use command "sudo rndc-confgen -a" to create a new password hash
   controls {
     inet 127.0.0.1 port 953
     allow { 127.0.0.1; } keys { "rndc-key"; };
   };
};

# Auto-generate the Bind9 rndc-key and write it to /etc/bind/rndc.key
sudo rndc-confgen -a -c /etc/bind/rndc.key -k rndc-key -r /dev/urandom

# Configure the named.conf.local file
sudo tee /etc/bind/named.conf.local > /dev/null <<EOF
zone "." {
   type hint;
   file "/etc/bind/db.root";
};

zone "localhost" {
   type master;
   file "/etc/bind/db.local";
};

zone "127.in-addr.arpa" {
   type master;
   file "/etc/bind/db.127";
};

zone "0.in-addr.arpa" {
   type master;
   file "/etc/bind/db.0";
};

zone "255.in-addr.arpa" {
   type master;
   file "/etc/bind/db.255";
};
EOF

# Backup the db.root file
sudo cp /etc/bind/db.root /etc/bind/db.root.bak

# Configure the root hints file
sudo tee /etc/bind/db.root > /dev/null <<EOF
.                        3600000  IN  NS  A.ROOT-SERVERS.NET.
A.ROOT-SERVERS.NET.      3600000  IN  A   198.41.0.4
EOF

# Restart Bind
sudo systemctl restart bind9

echo "Bind9 admin user password: $ADMIN_PASSWORD"
echo "Bind9 rndc-key: $RNDC_KEY"
