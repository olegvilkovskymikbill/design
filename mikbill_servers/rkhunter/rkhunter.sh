#!/bin/bash
TOKEN=xoxb-78422713744-425720419425-U3Men2QcEWZgFrXBTtTAUuEH
CHANNEL=events
USERNAME=events_bot
HOME_DIR=$(cd $(dirname $0)&& pwd)
tmp="$HOME_DIR/rkhunter.tmp"

rm -f $tmp

rkhunter --update
rkhunter -c --rwo >$tmp
rkhunter --propupd

actualsize=$(du -k "$tmp" | cut -f 1)
if [ $actualsize -ne 0 ]; then
DATA=$(<$tmp)
server_name="[TEST CENTOS] 194.28.89.161";
MESSAGE="$server_name $DATA"
#echo $MESSAGE
curl -s -X POST https://slack.com/api/chat.postMessage --data "token=$TOKEN&channel=$CHANNEL&text=$MESSAGE&username=$USERNAME&mrkdwn=true" >/dev/null
fi
