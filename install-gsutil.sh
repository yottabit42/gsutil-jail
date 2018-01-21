#!/bin/sh
#
# This script installs the Google Cloud SDK to enable the gsutil application. 
# Next, a script (gcp_backup.sh) that performs a gsutil rsync operation to
# backup local datasets to Google Storage is added to cron. Finally the script
# is called the first time instead of waiting for cron. Should any part of the
# script fail, hopefully it will just exit and leave the mess for the user to
# correct.
#
# Also available in a convenient Google Doc:
# https://docs.google.com/document/d/1LSr3J6hdnCDQHfiH45K3HMvEqzbug7GeUeDa_6b_Hhc
#
# Jacob McDonald
# Revision 180121a-yottabit
#
# Licensed under BSD-3-Clause, the Modified BSD License

configDir=$(dialog --no-lines --stdout --inputbox "Persistent storage is:" 0 0 \
"/config") || exit

if [ -d "$configDir" ] ; then
  echo "$configDir exists, like a boss!"
else
  echo "$configDir does not exist, so exiting (you might want to link a dataset)."
  exit
fi

/usr/sbin/pkg update
/usr/sbin/pkg upgrade --yes || exit
# Current version 183.0.0 is broken
# See https://issuetracker.google.com/issues/72263635
#/usr/sbin/pkg install --yes google-cloud-sdk || exit
/usr/sbin/pkg clean --yes || exit

# Install old version 94.0.0 of google-cloud-sdk for now
/usr/local/bin/curl --output google-cloud-sdk-94.0.0.0.txz \
http://pkg.freebsd.org/FreeBSD:11:amd64/release_0/All/google-cloud-sdk-94.0.0.txz
/usr/sbin/pkg install --yes ./google-cloud-sdk-94.0.0.0.txz
rm ./google-cloud-sdk-94.0.0.0.txz

gcloud init || exit

# add python path to crontab first
if grep '/usr/local/bin' "/etc/crontab"; then
  echo 'Python already in crontab path'
else
  sed -i '' -e 's~^PATH=.*~&:/usr/local/bin~' /etc/crontab || exit
fi
# add trigger to crontab
# default crontab trigger is daily at 0242 localtime
if grep 'gcp_backup.sh' "/etc/crontab"; then
  echo 'gcp_backup.sh already in crontab'
else
  echo "42 02 * * * root \"$configDir/gcp_backup.sh\" \
  >> \"$configDir/gcp_backup.log\" 2>&1" >> /etc/crontab || exit
fi
# kickoff the initial backup
"$configDir/gcp_backup.sh"
