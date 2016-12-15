#!/bin/bash
# Version 1
# Vilkovsky Oleg

Backup_routines=0
Backup_mikbill_files=1

Path_mikbill="/var/www/mikbill/"
Path_backup="/home/backupForUpdate/"

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

if [ "$Backup_routines" -ne 0 ];then
{
mysqldump --single-transaction --routines --extended-insert -u $DB_User -p$DB_Password mikbill | gzip > $Path_backup/"$Date"_backup_mikbill_DB_routines.sql.gz
}
else
{
mysqldump --single-transaction -u $DB_User -p$DB_Password mikbill | gzip > $Path_backup"$Date"_mikbill_DB.sql.gz
}

if [ "$Backup_mikbill_files" -ne 0 ];then
{
tar -czf $Path_backup"$Date"_mikbill_files.tar.gz 
}
