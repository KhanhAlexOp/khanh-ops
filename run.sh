#!/bin/bash

export AWS_CONFIG_FILE=./aws_config/config
export AWS_SHARED_CREDENTIALS_FILE=./aws_config/credentials
export AWS_ACCESS_KEY_ID=$(cat ./aws_config/access_key_id)
export AWS_SECRET_ACCESS_KEY=$(cat ./aws_config/secret_access_key)
export AWS_DEFAULT_REGION=$(cat ./aws_config/region)
echo $YOUR_ACCESS_KEY_ID
aws sts get-caller-identity

(cd terraform && terraform init)
(cd terraform && terraform plan && terraform apply -auto-approve)
(aws eks --region ap-southeast-1 update-kubeconfig --name khanh-eks &&
    kubectl apply -f k8s-manifests/deployment.yaml &&
    kubectl apply -f k8s-manifests/service.yaml &&
    kubectl apply -f k8s-manifests/hpa.yaml &&
    kubectl apply -f k8s-manifests/network-policy.yaml)