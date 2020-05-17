#!/usr/bin/env bash

# Commands used on the Bastion host
# Author: Andrew Jarombek
# Date: 2/15/2019

# Get SaintsXCTF database credentials (This currently isnt configured to work from the Bastion).
aws secretsmanager get-secret-value --secret-id saints-xctf-rds-prod-secret --region us-east-1

# Connect to the database.  Host will change
HOST="saints-xctf-mysql-database-dev.cmmi5k7ir20u.us-east-1.rds.amazonaws.com"
mysql -h ${HOST} -u saintsxctfdev -p

# Pass backup file to the database
mysql -h ${HOST} -u saintsxctfdev -D saintsxctf -p < saints-xctf-backup-dev.sql