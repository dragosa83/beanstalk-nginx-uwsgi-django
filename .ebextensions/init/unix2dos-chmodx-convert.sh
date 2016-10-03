#!/bin/bash
#
# File: init.sh
# Purpose: run several actions that do not pass easily directly in a config file

# Convert any possibly shell scripts edited in Windows, to Unix format
/bin/find /emind/ebextensions/ -type f -name '*.sh' -exec dos2unix {} \;

# Make sure our shell scripts have permissions that allow running them
/bin/find /emind/ebextensions/ -type f -name '*.sh' -exec chmod a+x {} \;

# Make sure our files do not allow access to anyone but the owner
/bin/find /emind/ebextensions/ -type f -exec chmod o=,g= {} \;