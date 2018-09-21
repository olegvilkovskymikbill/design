#!/bin/bash
server_name="[] ";
TOKEN=1xoxb-78422713744-425720419425-U3Men2QcEWZgFrXBTtTAUuEH
CHANNEL=1events
USERNAME=1events_bot

DATE=`date +%Y-%m-%d`
logdir=/var/log/aide
REPORT="Aide-"$DATE.txt
aidedir=/var/lib/aide/
aide --check >$logdir/check
cat $logdir/check|/bin/egrep "added|changed|removed" > $logdir/$REPORT

aide --update
cp $aidedir/aide.db.gz     $logdir/aide.db.gz-$DATE
mv $aidedir/aide.db.new.gz $aidedir/aide.db.gz

MESSAGE="$server_name, $(< $logdir/$REPORT)"
curl -s -X POST https://slack.com/api/chat.postMessage --data "token=$TOKEN&channel=$CHANNEL&text=$MESSAGE&username=$USERNAME&mrkdwn=true" >/dev/null
