#!/bin/bash
# Version 1
# Vilkovsky Oleg

Backup_routines=0

Path_mikbill="/var/www/mikbill/"
Path_backup="/home/backupForUpdate"

DB_User=""
DB_Password=""
DB_Name="mikbill"

Date=`date +%Y-%m-%d_%Hh%Mm`
GREEN='\033[0;32m'
NC='\033[0m'

MySQL_user (){
if [ "$DB_User" = "" ]
then
DB_User=$(cat $Path_mikbill'admin/app/etc/config.xml'| grep username | awk '{ gsub("<username>"," "); print }' | awk '{ gsub("</username>"," "); print }' | awk '{print $1}')
fi

if [ "$DB_Password" = "" ]
then
DB_Password=$(cat $Path_mikbill'admin/app/etc/config.xml'| grep password | awk '{ gsub("<password>"," "); print }' | awk '{ gsub("</password>"," "); print }' | awk '{print $1}')
fi
}

MySQL_dump (){
mkdir -p $Path_backup
echo -n "Backup routines? (y/n):"
read NUM
if [ "$NUM" = "y" -o "$NUM" = "Y" ] 
then
  echo -n "MySQL root password:"
  read DB_Password
  File=$Path_backup/DB_routines_"$Date".sql.gz
  mysqldump --single-transaction --routines --extended-insert -u root -p$DB_Password mikbill | gzip > $File
else
  MySQL_user
  File=$Path_backup/DB_"$Date".sql.gz
  mysqldump --single-transaction -u $DB_User -p$DB_Password mikbill | gzip > $File
fi

echo "MySQL dump:"
echo -e "${GREEN}$(du -h $File) $NC"
}

Mikbill_files_backup (){
File=$Path_backup/Files_"$Date".tar.gz
tar -czf $File $Path_mikbill
echo "Backup mikbill files $Path_mikbill:"
echo -e "${GREEN}$(du -h $File) $NC"
}

Dump_install (){
echo "This dir:"
Files=`ls -d1 $(cd $(dirname $0)&& pwd)/*.{sql.gz,sql}`
NUM=1
for x in $Files; do
echo " $NUM | $x $(stat -c%s "$x") b | $NUM"
DUMP[NUM]=$x
let "NUM=NUM+1"
done

echo "$Path_backup:"
Files=`ls -d1 $Path_backup/*.{sql.gz,sql}`
for x in $Files; do
echo " $NUM | $x $(stat -c%s "$x") b | $NUM"
DUMP[NUM]=$x
let "NUM=NUM+1"
done

while :
do
echo -n "What number dump install? :"
read NUM_DUMP
if [[ ${DUMP[NUM_DUMP]} ]];then
{
FILE=${DUMP[NUM_DUMP]}
echo -e -n "\e[31m Install dump $FILE? (y/n) : \e[0m"
read INSTALL
case "$INSTALL" in
y|Y)
if [ "${FILE##*.}" = "gz" ];then
{
MySQL_user
gunzip < ${DUMP[NUM_DUMP]} | mysql -u $DB_User -p$DB_Password mikbill
}
else
{
MySQL_user
mysql -u $DB_User -p$DB_Password mikbill < $FILE
}
fi
echo "Dump install"
exit
;;
esac
}
fi
done
}

echo -e " ${GREEN}Free space on $Path_backup: $NC"
echo "$(df -h $Path_backup)"

echo -e "[1]-MySQL dump \n[2]-MySQL dump + mikbill files \n[3]-Install dump"
echo -n "Enter:"
read NUM
case "$NUM" in
  1)
  MySQL_dump
  ;;
  2)
  MySQL_dump
  Mikbill_files_backup
  ;;
  3)
  Dump_install
  ;;
esac


