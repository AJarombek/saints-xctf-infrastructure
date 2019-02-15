#!/usr/bin/env bash

# Bash script which is run when the SaintsXCTF server instances first boot up
# Author: Andrew Jarombek
# Date: 12/11/2018

IP_ADDRESS="$(hostname -I)"
echo "Instance IP Address: ${IP_ADDRESS}"

sudo echo "ServerName ${IP_ADDRESS}" >> /etc/apache2/apache2.conf

sudo apache2ctl configtest
sudo systemctl restart apache2