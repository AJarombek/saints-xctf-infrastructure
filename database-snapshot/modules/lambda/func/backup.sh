#!/usr/bin/env bash

# Perform a MySQL database dump to back up the database
# Author: Andrew Jarombek
# Date: 6/8/2019

# Input Variables
ENV=$1
HOST=$2
USERNAME=$3
PASSWORD=$4

./mysqldump --host ${HOST} --opt -u ${USERNAME} -p ${PASSWORD} saintsxctf > backup.sql
aws s3 cp backup.sql s3://saints-xctf-db-backups-${ENV}/backup.sql