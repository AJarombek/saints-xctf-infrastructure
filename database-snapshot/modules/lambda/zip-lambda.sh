#!/usr/bin/env bash

# Zip all the required files for the AWS lambda function
# Author: Andrew Jarombek
# Date: 6/16/2019

echo "[START] zip-lambda.sh"

rm -r dist && mkdir dist
cp func dist

cd dist
pip install boto3 --target .

echo "[END] zip-lambda.sh"