#!/bin/bash
HOME_DIR=$(cd $(dirname $0)&& pwd)
source $HOME_DIR/radcash.conf

INQUIRY="SELECT MAX( gid ) FROM packets"
MAX_GID=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "$INQUIRY"`
MAX_GID=${MAX_GID:11:${#MAX_GID}}

INQUIRY="SELECT gid, speed_rate, speed_burst FROM packets"
SQL=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "$INQUIRY" 2>/dev/null`
SQL=${SQL:27:${#SQL}}

n=0
for i in $SQL; do
ARRAY_SQL[$n]=$i
let n=n+1
done

echo "/tool user-manager profile" >$UPLOAD_LIMITS
echo "limitation remove [find]" >>$UPLOAD_LIMITS
echo "remove numbers=[find]" >>$UPLOAD_LIMITS

for (( i=0; i <= $MAX_GID; i=i+3 ))
do
echo "limitation add name=${ARRAY_SQL[$i]} owner=admin rate-limit-rx=${ARRAY_SQL[$i+1]}k rate-limit-tx=${ARRAY_SQL[$i+2]}k" >>$UPLOAD_LIMITS
echo "add name=${ARRAY_SQL[$i]} owner=admin" >>$UPLOAD_LIMITS
echo "profile-limitation add profile=${ARRAY_SQL[$i]} limitation=${ARRAY_SQL[$i]}" >>$UPLOAD_LIMITS
done
