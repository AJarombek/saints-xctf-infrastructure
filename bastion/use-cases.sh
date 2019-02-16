#!/usr/bin/env bash

# Commands used on the Bastion host
# Author: Andrew Jarombek
# Date: 2/15/2019

# Connect to the database.  Host will change
HOST="saints-xctf-mysql-database-dev.cmmi5k7ir20u.us-east-1.rds.amazonaws.com"
mysql -h ${HOST} -u saintsxctfdev -p

# Pass backup file to the database
mysql -h ${HOST} -u saintsxctfdev -D saintsxctf -p < saints-xctf-backup-dev.sql