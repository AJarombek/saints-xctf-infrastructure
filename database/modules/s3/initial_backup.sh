#!/usr/bin/env bash

# Store an initial database backup on S3
# Author: Andrew Jarombek
# Since: 12/5/2018

aws --version

aws s3api put-object --bucket saints-xctf-db-backups --key saints-xctf-backup.sql --body saints-xctf-backup.sql