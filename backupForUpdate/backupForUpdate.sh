#!/bin/bash
# Version 1
# Vilkovsky Oleg



Path_mikbill="/var/www/mikbill"
Path_backup="/home/backupForUpdate"

DB_User=""
DB_Password=""
DB_Name="mikbill"

Date=`date +%Y-%m-%d_%Hh%Mm`

if [ "$DB_User" = "" ]
then
DB_User=$(cat $Path_mikbill'admin/app/etc/config.xml'| grep  username | awk '{ gsub("<username>"," "); print }' | awk '{ gsub("</username>"," "); print }' | awk '{print $1}')
fi

if [ "$DB_Password" = "" ]
then
DB_Password=$(cat $Path_mikbill'admin/app/etc/config.xml'| grep  password | awk '{ gsub("<password>"," "); print }' | awk '{ gsub("</password>"," "); print }' | awk '{print $1}')
fi

mkdir -p $Path_backup

mysqldump --single-transaction -u $DB_User -p$DB_Password mikbill | gzip > $Path_backup/"$Date"_backup_mikbill_DB.sql.gz
#mysqldump --single-transaction --routines --extended-insert -u $DB_User -p$DB_Password mikbill | gzip > $Path_backup/"$Date"_backup_mikbill_DB.sql.gz
