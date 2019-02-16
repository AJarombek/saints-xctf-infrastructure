#!/usr/bin/env bash

# Setup commands executed on the Bastion EC2 instance
# Author: Andrew Jarombek
# Date: 2/13/2019

# The MySQL source repository
sudo wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm

# Install all MySQL modules
sudo yum -y install mysql

# Retrieve the initial database backups from S3 and save them on the VM
cd ~
aws s3api get-object --bucket saints-xctf-db-backups-dev --key saints-xctf-backup.sql saints-xctf-backup-dev.sql
aws s3api get-object --bucket saints-xctf-db-backups-prod --key saints-xctf-backup.sql saints-xctf-backup-prod.sql