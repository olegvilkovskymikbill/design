#!/bin/bash
# Version 1
# Vilkovsky Oleg

Backup_routines=0

Path_mikbill="/var/www/mikbill/"
Path_backup="/home/backupForUpdate/"

DB_User=""
DB_Password=""
DB_Name="mikbill"

Date=`date +%Y-%m-%d_%Hh%Mm`
GREEN='\033[0;32m'
NC='\033[0m'

MySQL_dump (){
if [ "$DB_User" = "" ]
then
DB_User=$(cat $Path_mikbill'admin/app/etc/config.xml'| grep  username | awk '{ gsub("<username>"," "); print }' | awk '{ gsub("</username>"," "); print }' | awk '{print $1}')
fi

if [ "$DB_Password" = "" ]
then
DB_Password=$(cat $Path_mikbill'admin/app/etc/config.xml'| grep  password | awk '{ gsub("<password>"," "); print }' | awk '{ gsub("</password>"," "); print }' | awk '{print $1}')
fi

mkdir -p $Path_backup

if [ "$Backup_routines" -ne 0 ]
then
File=$Path_backup/"$Date"_backup_mikbill_DB_routines.sql.gz
mysqldump --single-transaction --routines --extended-insert -u $DB_User -p$DB_Password mikbill | gzip > $File
else
File=$Path_backup"$Date"_mikbill_DB.sql.gz
mysqldump --single-transaction -u $DB_User -p$DB_Password mikbill | gzip > $File
fi

echo -e " ${GREEN}MySQL dump: $File Size: ls -lh $File{NC}"
}

Mikbill_files_backup (){
tar -czf $Path_backup"$Date"_mikbill_files.tar.gz 
}

echo -e " ${GREEN}Free space on $Path_backup:{$NC}"
echo "$(df -h $Path_backup)"

echo -n "[1] - MySQL dump, [2] - MySQL dump + mikbill files:"
read NUM
case "$NUM" in
  1)
  MySQL_dump
  ;;
  2)
  MySQL_dump
  Mikbill_files_backup
  ;;
esac


