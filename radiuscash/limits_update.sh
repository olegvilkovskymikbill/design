#!/bin/bash
HOME_DIR=$(cd $(dirname $0)&& pwd)
source $HOME_DIR/radcash.conf

INQUIRY="SELECT MAX( gid ) FROM packets"
MAX_GID=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "$INQUIRY" 2>/dev/null`
MAX_GID=${MAX_GID:11:${#MAX_GID}}

INQUIRY="SELECT gid, speed_rate, speed_burst FROM packets"
SQL=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "$INQUIRY" 2>/dev/null`
SQL=${SQL:14:${#SQL}}

for (( i=0; i <= $MAX_GID; i++ ))
do
echo $SQL | awk '{print $2}
done
