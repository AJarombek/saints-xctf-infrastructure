#!/usr/bin/env bash

# Perform a MySQL database deployment
# Author: Andrew Jarombek
# Date: 9/18/2020

# Input Variables
ENV=$1
HOST=$2
USERNAME=$3
PASSWORD=$4

export MYSQL_PWD="${PASSWORD}"
/tmp/mysql -h ${HOST} -u ${USERNAME} saintsxctf < /tmp/script.sql
