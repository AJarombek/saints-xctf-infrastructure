#!/usr/bin/env bash

# Debugging use cases for the DEV environment launch configuration.
# Author: Andrew Jarombek
# Date: 2/21/2019

# Connect to auto-scaling group EC2 instance - host will change often
HOST_NAME="ec2-34-201-55-93.compute-1.amazonaws.com"
sudo ssh -i "saints-xctf-dev-key.pem" ubuntu@${HOST_NAME}

# Debug Apache Logs
tail /var/log/apache2/error.log -n 100

# Execute PHP from the command line
php -r 'echo getenv("ENV");'

php -r "\$db = new PDO(\"mysql:host=saints-xctf-mysql-database-dev.cmmi5k7ir20u.us-east-1.rds.amazonaws.com;dbname=saintsxctf;charset=utf8\", \"${Username}\", \"${Password}\");"