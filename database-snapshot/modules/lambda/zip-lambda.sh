#!/usr/bin/env bash

# Zip all the required files for the AWS lambda function
# Author: Andrew Jarombek
# Date: 6/16/2019

rm -r dist && mkdir dist
cp func dist

cd dist
pip install boto3 --target .