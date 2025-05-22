#!/bin/bash

cd terraform

echo "Creating infrastructure using terraform..."
terraform init
terraform fmt
terraform apply --auto-approve

echo "Waiting for infrastructure to be ready..."
sleep 60

cd ../ansible

echo "Running ansible playbook..."

ansible-playbook -i hosts.ini site.yml

