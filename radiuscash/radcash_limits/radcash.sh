#!/bin/bash
HOME_DIR=$(cd $(dirname $0)&& pwd)
source $HOME_DIR/radcash.conf
source $HOME_DIR/radcash.lib


# Тарифы
FUNC_MAX_GID
let "MAX_GID=MAX_GID*3"

QUERY="SELECT gid, speed_burst, speed_rate FROM packets"
SQL=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "$QUERY" 2>/dev/null`
SQL=${SQL:27:${#SQL}}

n=0
for i in $SQL; do
ARRAY_SQL[$n]=$i
let n=n+1
done

echo "/tool user-manager profile" >$UPLOAD
echo "limitation remove [find]" >>$UPLOAD
echo "remove numbers=[find]" >>$UPLOAD

for (( i=0; i < $MAX_GID; i=i+3 ))
do

if [ "${ARRAY_SQL[$i]}" != "" ]
then
echo "limitation add name=${ARRAY_SQL[$i]} owner=admin rate-limit-rx=${ARRAY_SQL[$i+1]}k rate-limit-tx=${ARRAY_SQL[$i+2]}k" >>$UPLOAD
echo "add name=${ARRAY_SQL[$i]} owner=admin" >>$UPLOAD
echo -e "profile-limitation add profile=${ARRAY_SQL[$i]} limitation=${ARRAY_SQL[$i]} \n" >>$UPLOAD
fi

done

# Абоненты
FUNC_MAX_UID

if [ "$LOG_REMOVE" -ne 0 ]
then
echo "/tool user-manager log remove numbers=[find]" >>$UPLOAD
fi

echo "/tool user-manager user" >>$UPLOAD
echo "remove [find]" >>$UPLOAD

UID_TO_USERS

if [ "$RADIUS_HOTSPOT" -ne 0 ]
then
FUNC_HOTSPOT
fi

if [ "$RADIUS_PPP" -ne 0 ]
then
FUNC_PPP
fi

SSH_UPLOAD "$USERMAN_IP" "$USERMAN_SSH_PORT" "$USERMAN_LOGIN"
# SSH_UPLOAD "$USERMAN_IP_1" "$USERMAN_SSH_PORT_1" "$USERMAN_LOGIN_1"
