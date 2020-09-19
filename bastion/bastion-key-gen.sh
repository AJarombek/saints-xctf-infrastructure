#!/usr/bin/env bash

# Generate a key to connect to the bastion host.  This script must execute BEFORE the bastion host is created.
# Author: Andrew Jarombek
# Date: 2/13/2019

export AWS_DEFAULT_REGION=us-east-1

# Used to preserve newlines in the private key.  Otherwise the key has an invalid format.
# https://unix.stackexchange.com/a/164548
IFS=

# First delete any exiting key pair with the name "bastion-key"
aws ec2 delete-key-pair --key-name bastion-key

# Next create a new keypair.  Query the results back from AWS to get the private key
BastionKey="$(aws ec2 create-key-pair --key-name bastion-key --query "KeyMaterial" --output text)"

# In case needed, display the private key
echo ${BastionKey}

# Place the private key in a file called bastion-key.pem
echo ${BastionKey} > ~/bastion-key.pem

# Its recommended to change the private key permissions
chmod 400 ~/bastion-key.pem