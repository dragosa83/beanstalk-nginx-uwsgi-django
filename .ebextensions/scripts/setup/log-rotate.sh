#!/bin/bash

source /emind/ebextensions/scripts/env.sh

#Clear the crontab
echo '' | crontab -

#add logrotate jobs to cron:
crontab -l > /tmp/tmp_cron
echo '*/5 * * * * /emind/ebextensions/scripts/cron-jobs/log-rotate.sh' >> /tmp/tmp_cron
echo '# Force log rotation at 07:00 UTC' >> /tmp/tmp_cron
echo '0 7 * * * /emind/ebextensions/scripts/cron-jobs/log-rotate.sh -f' >> /tmp/tmp_cron
echo '# Force log rotation at 08:00 UTC' >> /tmp/tmp_cron
echo '0 8 * * * /emind/ebextensions/scripts/cron-jobs/log-rotate.sh -f' >> /tmp/tmp_cron
crontab /tmp/tmp_cron
