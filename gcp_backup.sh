#!/bin/sh
#
# This script runs gsutil rsync to synchronize several local datasets to Google
# Cloud Storage for backup. The -m flag is used to parallelize the operation. If
# the Internet connectivity is typical residential speeds of 10 Mbps upstream or
# less, performance will likely suffer without removing the -m flag.
#
# Customization of the paths in this script are expected to be performed by the
# user.
#
# Also available in a convenient Google Doc:
# https://docs.google.com/document/d/1LSr3J6hdnCDQHfiH45K3HMvEqzbug7GeUeDa_6b_Hhc
#
# Jacob McDonald
# Revision 170422a-yottabit
#
# Licensed under BSD-3-Clause, the Modified BSD License

# Define the root directory of your backups here
backupRoot="/config"

# Define the Google Cloud Storage bucket name
bucketName="gs://your-bucket-name"

# Do some checks to ensure backup datasets are mounted
[ ! -d "$backupRoot/Documents" ] && \
echo "$backupRoot/Documents is missing, so exiting" && exit
[ ! -d "$backupRoot/Music" ] && \
echo "$backupRoot/Music is missing, so exiting" && exit
[ ! -d "$backupRoot/Pictures" ] && \
echo "$backupRoot/Pictures is missing, so exiting" && exit
[ ! -d "$backupRoot/Video" ] && \
echo "$backupRoot/Video is missing, so exiting" && exit

echo Started `date`
#dry-run with -n because mistakes cost money
#time /usr/local/bin/gsutil -m rsync -rCdn "$backupRoot" "$bucketName"

time /usr/local/bin/gsutil -m rsync -rCd "$backupRoot" "$bucketName"

echo Finished `date`
