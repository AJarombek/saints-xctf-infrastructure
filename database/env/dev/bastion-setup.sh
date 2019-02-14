#!/usr/bin/env bash

# Setup commands executed on the Bastion EC2 instance
# Author: Andrew Jarombek
# Date: 2/13/2019

# The MySQL source repository
sudo wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm

# Install all MySQL modules
sudo yum -y install mysql