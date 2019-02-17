#!/usr/bin/env bash

# Store an initial database backup on S3
# Author: Andrew Jarombek
# Since: 12/5/2018

# The environment for the backups depends on the first argument of the script
ENV=$1

# Test the AWS cli version
aws --version

# Put the local backup file onto S3
aws s3api put-object --bucket saints-xctf-db-backups-${ENV} --key saints-xctf-backup.sql --body \
        ../../modules/s3/saints-xctf-backup.sql