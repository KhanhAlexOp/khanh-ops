#!/bin/bash

export AWS_CONFIG_FILE=./aws_config/config
export AWS_SHARED_CREDENTIALS_FILE=./aws_config/credentials

echo $YOUR_ACCESS_KEY_ID
aws sts get-caller-identity

(cd terraform && terraform init)
(cd terraform && terraform plan && terraform apply -auto-approve)