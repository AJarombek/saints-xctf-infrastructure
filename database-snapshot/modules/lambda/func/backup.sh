#!/usr/bin/env bash

# Perform a MySQL database dump to back up the database
# Author: Andrew Jarombek
# Date: 6/8/2019

# Input Variables
ENV=$1
HOST=$2
USERNAME=$3
PASSWORD=$4

cp ./mysqldump /tmp/mysqldump
chmod 755 /tmp/mysqldump

export MYSQL_PWD="${PASSWORD}"
/tmp/mysqldump -v --host ${HOST} --user ${USERNAME} --max_allowed_packet=1G --single-transaction --quick \
    --lock-tables=false --routines saintsxctf > /tmp/backup.sql