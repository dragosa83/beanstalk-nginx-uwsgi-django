#!/bin/bash

mkdir -p /emind/tmp
cd /emind/tmp

#The latest S3Cmd release needs this dependency to be installed
yum install python-dateutil -y

#Clean up previous packages
rm -rf s3cmd-*

#Unpack the kit
tar -xvf /emind/ebextensions/packages/s3cmd-*.tgz

#Do the install
cd s3cmd-*
/usr/bin/python setup.py install

