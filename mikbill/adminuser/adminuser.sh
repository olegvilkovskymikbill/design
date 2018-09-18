#!/bin/bash
PATH_MIKBILL=/var/www/mikbill/
DB_USER=$(cat $PATH_MIKBILL'app/etc/config.xml'| grep  username | awk '{ gsub("<username>"," "); print }' | awk '{ gsub("</username>"," "); print }' | awk '{print $1}')
DB_PASSWORD=$(cat $PATH_MIKBILL'app/etc/config.xml'| grep  password | awk '{ gsub("<password>"," "); print }' | awk '{ gsub("</password>"," "); print }' | awk '{print $1}')

SQL=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "USE MIKBILL;"
SQL=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "select * from stuff_personal;"



#mysql -u$DB_USER -p$DB_PASSWORD
#USE mikbill;
#select * from stuff_personal;
