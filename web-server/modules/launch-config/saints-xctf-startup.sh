#!/usr/bin/env bash

# Bash script which is run when the SaintsXCTF server instances first boot up
# Author: Andrew Jarombek
# Date: 12/11/2018

echo "[Start] saints-xctf-startup.sh"

# Add the application files not in version control
sudo aws s3api get-object --bucket saints-xctf-credentials-${ENV} --key date.js /var/www/html/date.js
sudo aws s3api get-object --bucket saints-xctf-credentials-${ENV} --key api/cred.php /var/www/html/api/cred.php
sudo aws s3api get-object --bucket saints-xctf-credentials-${ENV} --key api/apicred.php /var/www/html/api/apicred.php
sudo aws s3api get-object --bucket saints-xctf-credentials-${ENV} --key \
        models/clientcred.php /var/www/html/models/clientcred.php

# The SaintsXCTF application looks at this environment variable to determine which API URL to use
sudo bash -c echo "\"ENV=\"${ENV}\"\" >> /etc/environment"

# Execute a python script which alters the Apache config for the given environment
cd /home/ubuntu
sudo chmod +x apache-config.py
sudo ./apache-config.py ${ENV}

# Enable the new SaintsXCTF config for Apache and disable the default config
sudo a2ensite saintsxctf.com.conf
sudo a2dissite 000-default.conf

sudo apache2ctl configtest
sudo systemctl restart apache2

# Find the DNS record for the SaintsXCTF application
HostedZoneId="$(aws route53 list-hosted-zones-by-name --dns-name ${DOMAIN} --query "HostedZones[0].Id")"

SaintsXCTFRecord="$(aws route53 list-resource-record-sets --hosted-zone-id /hostedzone/Z27198R4O4VUH4 \
     --query "ResourceRecordSets[?Name == '${SUBDOMAIN}'].Name" --output text)"

# If the DNS record already exists, proceed with setting up certbot
if [[ -z "${SaintsXCTFRecord}" ]]
then
    echo "DNS not ready for Certbot!"
else
    echo "Configuring Certbot..."
    sudo certbot -n --apache --agree-tos --email andrew@jarombek.com -d saintsxctf${ENV}.jarombek.io --redirect
fi

# Make sure the Apache configuration changes are valid and restart the web server
sudo apache2ctl configtest
sudo systemctl restart apache2

echo "[End] saints-xctf-startup.sh"