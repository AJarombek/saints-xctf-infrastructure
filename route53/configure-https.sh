#!/usr/bin/env bash

# Configure the SaintsXCTF applications Apache web server with HTTPS
# Author: Andrew Jarombek
# Date: 2/24/2019

# Set up HTTPS for Apache
sudo certbot -n --apache --agree-tos --email andrew@jarombek.com -d saintsxctf${ENV}.jarombek.io --redirect

# Make sure the Apache configuration changes are valid and restart the web server
sudo apache2ctl configtest
sudo systemctl restart apache2