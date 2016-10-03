#!/bin/bash
INSTANCE_ID=$(curl -XGET http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -XGET http://instance-data/latest/meta-data/placement/availability-zone | sed 's/.$//')
ENV_NAME=$(aws ec2 describe-tags --region $REGION --filter "Name=resource-id,Values=$INSTANCE_ID" --output=text | sed -r 's/TAGS\t(.*)\t.*\t.*\t(.*)/\1="\2"/'| grep environment-name | awk -F '=' '{ print $2}' | tr -d '"')
# 02-get-beanstalk-enviroment-resources:
ELB_NAME=$(aws elasticbeanstalk describe-environment-resources --environment-name $ENV_NAME --output=json --region $REGION | grep -A 2 LoadBalancers | grep Name | awk -F '"' '{ print $4}')
# 05-enable-access-logs:
aws elb modify-load-balancer-attributes --load-balancer-name $ELB_NAME --load-balancer-attributes file:///emind/ebextensions/init/enable-elb-logs.json --output=json --region $REGION