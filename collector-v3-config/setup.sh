#!/bin/bash

echo "set cloudwatch agent config ..."
echo "Write aws config"
sudo mkdir -p /root/.aws
echo "[profile AmazonCloudWatchAgent]" | sudo tee -a /root/.aws/config
echo "region = eu-west-3" | sudo tee -a /root/.aws/config
# Copy secret key and access key from /etc/greengo/hal.env to /root/.aws/credentials
echo "[AmazonCloudWatchAgent]" | sudo tee -a /root/.aws/credentials
echo "aws_access_key_id = $(grep AWS_ACCESS_KEY_ID /etc/greengo/hal.env | cut -d "=" -f 2)" | sudo tee -a /root/.aws/credentials
echo "aws_secret_access_key = $(grep AWS_SECRET_ACCESS_KEY /etc/greengo/hal.env | cut -d "=" -f 2)" | sudo tee -a /root/.aws/credentials

mv ./amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/