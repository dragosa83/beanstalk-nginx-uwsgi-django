#!/bin/bash

source /emind/ebextensions/scripts/env.sh

function write_log()
{
    logger -t "POSTROTATE SCRIPT" "${*}"
}

echo $ENV_NAME


if [ -z "$ENV_NAME" ]; then
    echo "ENV_NAME is empty"
    write_log "ENV_NAME is empty"
    exit 0
fi


INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
TODAY=`date +%Y-%m-%d`
TEMP_DIRECTORY="/tmp/temp_log_dir_do_not_delete"
LOGS_DIRECTORY="/local/rotated_logs_do_not_delete"

if [ ! -d ${TEMP_DIRECTORY} ]; then
    mkdir "${TEMP_DIRECTORY}"
fi

if [ ! -d ${TEMP_DIRECTORY} ]; then
    write_log "Temp directory ( ${TEMP_DIRECTORY} ) doesn't exist. The script cannot continue."
    exit 1
fi

if [ ! -d ${LOGS_DIRECTORY} ]; then
    mkdir "${LOGS_DIRECTORY}"
fi

if [ ! -d ${LOGS_DIRECTORY} ]; then
    write_log "Logs directory ( ${LOGS_DIRECTORY} ) doesn't exist. The script cannot continue."
    exit 1
fi

#keep only 100 versions of rotated logs locally:
function garbage_collect()
{
LOG_FILE_NAME=(access.log error.log)
for i in ${LOG_FILE_NAME[@]} ;
do
        FILE_NUMBER=$(ls | grep "$i" | wc -l)
        if [[ $FILE_NUMBER > 100 ]]  ; then
                FILES_TO_DELETE=$(ls -t | grep $i | tail -1)
                rm -rf $FILES_TO_DELETE
        fi;
done
}
INITIAL_FILE_NAME=$(basename ${1})
SOURCE_DIR=$(dirname ${1})
S3_DESTINATION=""

write_log "starting postrotate for ${INITIAL_FILE_NAME}"

#Set the destination S3 link according to the log file being processed
case "${INITIAL_FILE_NAME}" in
    access.log)
        S3_DESTINATION="s3://unbotify-app-logs/${ENV_NAME}/event-logs/${TODAY}/"
        ;;
    error.log)
        S3_DESTINATION="s3://unbotify-app-logs/${ENV_NAME}/error-logs/${TODAY}/"
        ;;
    *)
        write_log "Unconfigured log file. The script will exit."
        ;;
esac

#If it cannot determine the destination S3 bucket the script will exit
if [ -z ${S3_DESTINATION} ]; then
    exit 2
fi

#Find the log files according to the log name that have been accessed less the 15 minutes ago. This should find only
#the last rotated log file.
#After finding it copy it to ***** and remane it appending the Instance ID
find "${SOURCE_DIR}/" -type f -name "${INITIAL_FILE_NAME}-*" -cmin -6 -execdir cp {} "${TEMP_DIRECTORY}/" \;

find "${SOURCE_DIR}/" -type f -name "${INITIAL_FILE_NAME}-*" -execdir mv {} "${LOGS_DIRECTORY}/" \;

find "${TEMP_DIRECTORY}/" -type f -name "${INITIAL_FILE_NAME}-*" -execdir mv {} {}-$INSTANCE_ID \;

##Check if the file has been copied to the temporary directory
#if [ ! -f "${TEMP_DIRECTORY}/${NEW_FILE_NAME}" ]; then
#    write_log "Missing temporary file ( ${TEMP_DIRECTORY}/${NEW_FILE_NAME} )"
#    exit 3
#if

#Upload the file to S3
/usr/bin/s3cmd --config /emind/ebextensions/conf/s3cmd.conf --server-side-encryption sync "${TEMP_DIRECTORY}/${INITIAL_FILE_NAME}"-* "${S3_DESTINATION}"
#aws s3 sync "${TEMP_DIRECTORY}/${INITIAL_FILE_NAME}"-* "${S3_DESTINATION}"

#RESULT=$?
#echo $RESULT

#In the end, garbage collect :
cd ${LOGS_DIRECTORY}/ && garbage_collect  
find "${TEMP_DIRECTORY}/" -type f -name "${INITIAL_FILE_NAME}-*" -execdir rm -f {} \;

write_log "postrotate for ${INITIAL_FILE_NAME} completed successfully"


