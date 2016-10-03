#!/bin/bash

#source /emind/ebextensions/scripts/env.sh

#echo $ENV_NAME

#if [ -z "$ENV_NAME" ]; then
#    logger "ENV_NAME is empty"
 #   exit 0
#fi

FORCE=""

# Process the command-line parameters
while getopts "f" options; do
  case $options in
    f)FORCE="-f";;
  esac
done

/usr/sbin/logrotate ${FORCE} --state /emind/ebextensions/scripts/logrotate.state /emind/ebextensions/conf/logrotate.conf &&

/emind/ebextensions/scripts/postrotate.sh /var/log/access.log
/emind/ebextensions/scripts/postrotate.sh /var/log/error.log

#s3cmd --config /emind/ebextensions/conf/s3cmd.conf put /var/app/current/log/usage.log-* s3://tx-usage/${ENV_NAME}/log-files/ &&
#s3cmd --config /emind/ebextensions/conf/s3cmd.conf put /var/app/current/log/events.log-* s3://events-logs/${ENV_NAME}/ &&
#s3cmd --config /emind/ebextensions/conf/s3cmd.conf put /var/app/current/log/internal_requests.log-* s3://gw-fe_requests_logs/${ENV_NAME}/ &&
#s3cmd --config /emind/ebextensions/conf/s3cmd.conf put /var/app/current/log/requests.log-* s3://gw-fe_requests_logs/${ENV_NAME}/
