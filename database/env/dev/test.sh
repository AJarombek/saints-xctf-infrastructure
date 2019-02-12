#!/usr/bin/env bash

# Testing the connection to MySQL
# Author: Andrew Jarombek
# Date: 2/10/2019

## From MacOS ##
brew install mysql

# Shouldn't work since I'm trying to connect from outside the VPC
mysql -h saints-xctf-mysql-database-dev.cmmi5k7ir20u.us-east-1.rds.amazonaws.com -u saintsxctfdev