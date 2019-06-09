#!/usr/bin/env bash

# Perform a MySQL database dump to back up the database
# Author: Andrew Jarombek
# Date: 6/8/2019

./mysqldump --host ${HOST} --opt -u ${USERNAME} -p ${PASSWORD} saintsxctf