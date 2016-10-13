#!/bin/bash
USERMAN_IP="192.168.10.150"
USERMAN_LOGIN="mikbill"
USERMAN_PASSWORD="mikbill"
UPLOAD="userman.rsc"
PATH_CONFIG=/var/www/mikbill/admin/app/etc/config.xml
DB_USER=$(cat $PATH_CONFIG| grep  username | awk '{ gsub("<username>"," "); print }' | awk '{ gsub("</username>"," "); print }' | awk '{print $1}')
DB_PASSWORD=$(cat $PATH_CONFIG| grep  password | awk '{ gsub("<password>"," "); print }' | awk '{ gsub("</password>"," "); print }' | awk '{print $1}')
DB_NAME=$(cat $PATH_CONFIG | grep dbname | awk '{ gsub("<dbname>"," "); print }' | awk '{ gsub("</dbname>"," "); print }'| awk '{print $1}')

HOME_DIR=$(cd $(dirname $0)&& pwd)

MAC=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "SELECT local_mac FROM users" 2>/dev/null`
MAC=${MAC:10:${#MAC}}

echo "/tool user-manager user remove [find]" > $HOME_DIR/$UPLOAD
for i in $MAC; do
echo "/tool user-manager user add customer=admin name=$i" >>$HOME_DIR/$UPLOAD
done

curl --upload-file $HOME_DIR/$UPLOAD  ftp://$USERMAN_LOGIN:$USERMAN_PASSWORD@$USERMAN_IP/
CMD="/import file=$UPLOAD"
ssh $USERMAN_LOGIN@$USERMAN_IP "${CMD}" > /dev/null
