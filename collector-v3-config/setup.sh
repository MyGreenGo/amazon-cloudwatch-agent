#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Set hostname to ethernet mac address without colons
echo "set hostname ..."
echo "1. Get mac address"
MAC_ADDRESS=$(cat /sys/class/net/eth0/address | sed 's/://g')
echo "127.0.0.1 $MAC_ADDRESS" | sudo tee -a /etc/hosts
echo "2. Set hostname to $MAC_ADDRESS"
sudo hostname $MAC_ADDRESS
echo  $MAC_ADDRESS | sudo tee /etc/hostname

# Install aws cloudwatch agent config (https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html)
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

# Add or update a cron job to restart the cloudwatch agent every day at midnight to force log stream name to update to new date
echo "set cron job ..."
if [ -f /etc/cron.d/restart-cloudwatch-agent ]; then
    rm /etc/cron.d/restart-cloudwatch-agent
fi
echo "0 0 * * * root systemctl restart amazon-cloudwatch-agent" | sudo tee -a /etc/cron.d/restart-cloudwatch-agent

# Enable cloudwatch agent service to start at boot
sudo systemctl enable amazon-cloudwatch-agent
