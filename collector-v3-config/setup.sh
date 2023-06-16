#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "set cloudwatch agent config ..."
echo "Write aws config"
sudo mkdir -p /root/.aws
echo "[profile AmazonCloudWatchAgent]" | sudo tee -a /root/.aws/config
echo "region = eu-west-3" | sudo tee -a /root/.aws/config
# Copy secret key and access key from /etc/greengo/hal.env to /root/.aws/credentials
echo "[AmazonCloudWatchAgent]" | sudo tee -a /root/.aws/credentials
echo "aws_access_key_id = $(grep AWS_ACCESS_KEY_ID /etc/greengo/hal.env | cut -d "=" -f 2)" | sudo tee -a /root/.aws/credentials
echo "aws_secret_access_key = $(grep AWS_SECRET_ACCESS_KEY /etc/greengo/hal.env | cut -d "=" -f 2)" | sudo tee -a /root/.aws/credentials

if [ -f /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json ]; then
    mv /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json.bak
fi
# Move config file to /opt/aws/amazon-cloudwatch-agent/etc/ taking into account that this script might not be launched from the same directory
mv $(dirname "$0")/amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/

sudo systemctl restart amazon-cloudwatch-agent