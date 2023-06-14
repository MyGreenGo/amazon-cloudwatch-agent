#! /bin/bash

if [ -f /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json.bak ]; then
    mv /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json.bak /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
fi

sudo systemctl restart amazon-cloudwatch-agent
