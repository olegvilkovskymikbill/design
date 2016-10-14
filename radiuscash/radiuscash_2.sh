#!/bin/bash
USERMAN_IP="192.168.10.66"
USERMAN_LOGIN="mikbill"
USERMAN_PASSWORD="mikbill"

#RADIUS_TYPE="hotspot"
RADIUS_TYPE="ppp"

HOME_DIR=$(cd $(dirname $0)&& pwd)
UPLOAD=$HOME_DIR/userman.rsc
LIST_NEW=$HOME_DIR/list.new
LIST_OLD=$HOME_DIR/list.old
PATH_CONFIG=/var/www/mikbill/admin/app/etc/config.xml
DB_USER=$(cat $PATH_CONFIG| grep  username | awk '{ gsub("<username>"," "); print }' | awk '{ gsub("</username>"," "); print }' | awk '{print $1}')
DB_PASSWORD=$(cat $PATH_CONFIG| grep  password | awk '{ gsub("<password>"," "); print }' | awk '{ gsub("</password>"," "); print }' | awk '{print $1}')
DB_NAME=$(cat $PATH_CONFIG | grep dbname | awk '{ gsub("<dbname>"," "); print }' | awk '{ gsub("</dbname>"," "); print }'| awk '{print $1}')

INQUIRY="SELECT MAX( uid ) FROM users"
MAX=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "$INQUIRY" 2>/dev/null`
MAX=${MAX:11:${#MAX}}

INQUIRY="SELECT uid FROM users WHERE credit >= ABS (deposit) and blocked=0"
SQL=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "$INQUIRY" 2>/dev/null`
SQL=${SQL:4:${#SQL}}

for i in $SQL; do
ARRAY_UID[$i]="1"
done

rm $LIST_NEW
for (( i=0; i <= $MAX; i++ ))
do
if [[ ${ARRAY_UID[$i]} -eq 1 ]]
then
echo "1" >> $LIST_NEW
else
echo "0" >> $LIST_NEW
fi
done

if !([ -e "$TAR_EXCLUDE_LIST" ])then
#cp $LIST_NEW $LIST_OLD

# version 2
# wget https://github.com/mikbill/design/raw/master/radiuscash/radiuscash_2.sh

