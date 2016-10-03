#!/bin/bash

find /emind/ebextensions/ -type f -name '*.sh' -exec dos2unix {} \;
find /emind/ebextensions/ -type f -name '*.sh' -exec chmod a+x {} \;

source /emind/ebextensions/scripts/env.sh

/emind/ebextensions/scripts/setup/s3-cmd.sh
/emind/ebextensions/scripts/setup/log-rotate.sh

#ensure logrotate and upload to s3 runs before shutdown:
cp /emind/ebextensions/conf/upload_to_S3.conf /etc/init/
chown root:root /etc/init/upload_to_S3.conf

#send syslog messages to Graylog:
echo "*.* @ip-172-17-4-208.ec2.internal:514" >> /etc/rsyslog.conf
#/etc/init.d/emind-monitor start

# Prepare post-deployment scripts
if [ ! -d /opt/elasticbeanstalk/hooks/appdeploy/post ]; then
  mkdir -p /opt/elasticbeanstalk/hooks/appdeploy/post
fi
rm -f /opt/elasticbeanstalk/hooks/appdeploy/post/*
mv /emind/ebextensions/scripts/setup/logdir-config.sh /opt/elasticbeanstalk/hooks/appdeploy/post/