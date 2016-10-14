#!/bin/bash
USERMAN_IP="192.168.10.66"
USERMAN_LOGIN="mikbill"
USERMAN_PASSWORD="mikbill"

#RADIUS_TYPE="hotspot"
RADIUS_TYPE="ppp"

UPLOAD="userman.rsc"
PATH_CONFIG=/var/www/mikbill/admin/app/etc/config.xml
DB_USER=$(cat $PATH_CONFIG| grep  username | awk '{ gsub("<username>"," "); print }' | awk '{ gsub("</username>"," "); print }' | awk '{print $1}')
DB_PASSWORD=$(cat $PATH_CONFIG| grep  password | awk '{ gsub("<password>"," "); print }' | awk '{ gsub("</password>"," "); print }' | awk '{print $1}')
DB_NAME=$(cat $PATH_CONFIG | grep dbname | awk '{ gsub("<dbname>"," "); print }' | awk '{ gsub("</dbname>"," "); print }'| awk '{print $1}')

HOME_DIR=$(cd $(dirname $0)&& pwd)

INQUIRY="SELECT uid FROM users WHERE credit >= ABS (deposit) and blocked=0"
SQL=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "$INQUIRY" 2>/dev/null`

# version 2
# 
