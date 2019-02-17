#!/usr/bin/env bash

# Bash script which is run when the SaintsXCTF server instances first boot up
# Author: Andrew Jarombek
# Date: 12/11/2018

# Get the IP address of the instance
IP_ADDRESS="$(hostname -I)"
echo "Instance IP Address: ${IP_ADDRESS}"

# Configure the Apache web server
DOMAIN="saintsxctf${ENV}.jarombek.io"

sudo echo "ServerName ${DOMAIN}" >> /etc/apache2/apache2.conf

# Add the application files not in version control
aws s3api get-object --bucket saints-xctf-credentials-${ENV} --key date.js /var/www/html/date.js
aws s3api get-object --bucket saints-xctf-credentials-${ENV} --key api/cred.php /var/www/html/api/cred.php
aws s3api get-object --bucket saints-xctf-credentials-${ENV} --key api/apicred.php /var/www/html/api/apicred.php
aws s3api get-object --bucket saints-xctf-credentials-${ENV} --key \
        models/clientcred.php /var/www/html/models/clientcred.php

sudo apache2ctl configtest
sudo systemctl restart apache2