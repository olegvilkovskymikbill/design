#!/bin/bash
PATH_MIKBILL=/var/www/mikbill/admin/
DB_NAME=mikbill
DB_USER=$(cat $PATH_MIKBILL'app/etc/config.xml'| grep  username | awk '{ gsub("<username>"," "); print }' | awk '{ gsub("</username>"," "); print }' | awk '{print $1}')
DB_PASSWORD=$(cat $PATH_MIKBILL'app/etc/config.xml'| grep  password | awk '{ gsub("<password>"," "); print }' | awk '{ gsub("</password>"," "); print }' | awk '{print $1}')
SQL=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "select login, pass from stuff_personal;"`
echo $SQL

