#!/usr/bin/env bash

# Rotate Secrets Manager secret immediately after the infrastructure is created.  This can't be done in
# Terraform HCL code.
# Author: Andrew Jarombek
# Date: 6/1/2020

ENV=$1

aws secretsmanager rotate-secret --secret-id saints-xctf-auth-${ENV}