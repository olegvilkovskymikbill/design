#!/bin/bash
#Client DNS
DNS1=192.168.10.1
DNS2=8.8.8.8
# Mikrotik
MT_SSH_PORT="22"
IP_TO_ADDRESS_LIST=1
IP_TO_WALLED_GARDEN_IP_LIST=1

Path_Config=/var/www/mikbill/admin/app/etc/config.xml

SSH_INTERVAL=10
SSH_SUM=10

DIG=`which dig`
IPSETNAME="nomoney_dst_accept"

HOME_DIR=$(cd $(dirname $0)&& pwd)
SRCDATA=`cat $HOME_DIR/domains.list`
IPLIST="$HOME_DIR/ip.list"
UPLOAD=$HOME_DIR/upload_paysys.rsc
ADDRESS_LIST="nomoney_dst_accept"

TMP=$HOME_DIR/tmp

RESULT="$($DIG +short $SRCDATA @$DNS1 |grep '\([[:digit:]]\{1,3\}\.\)\{3\}[[:digit:]]\{1,3\}') $($DIG +short $SRCDATA @$DNS2 |grep '\([[:digit:]]\{1,3\}\.\)\{3\}[[:digit:]]\{1,3\}') $(cat $IPLIST)"

echo >$UPLOAD

if [ "$IP_TO_ADDRESS_LIST" -ne 0 ]
then
echo "/ip firewall address-list remove [/ip firewall address-list find list=$ADDRESS_LIST]" >>$UPLOAD
fi

if [ "$IP_TO_WALLED_GARDEN_IP_LIST" -ne 0 ]
then
echo "/ip hotspot walled-garden ip remove numbers=[/ip hotspot walled-garden ip find comment=$ADDRESS_LIST]" >>$UPLOAD
fi

touch $TMP
for i in $RESULT; do
if ! grep -q $i $TMP
then

if [ "$IP_TO_ADDRESS_LIST" -ne 0 ]
then
echo "/ip firewall address-list add list="$ADDRESS_LIST" address=$i" >>$UPLOAD
fi

if [ "$IP_TO_WALLED_GARDEN_IP_LIST" -ne 0 ]
then
echo "/ip hotspot walled-garden ip add comment=$ADDRESS_LIST dst-address=$i" >>$UPLOAD
fi

echo $i >>$TMP
fi
done
rm $TMP

SSH_UPLOAD (){
for (( i=0;i!=$SSH_SUM;i++ )); do

scp -P $MT_SSH_PORT $UPLOAD $MT_LOGIN@$MT_IP:/
STATUS=$?
if [ $STATUS -ne 0 ]; then
sleep $SSH_INTERVAL
else

CMD="/import file=$(basename $UPLOAD)"
for (( i=0;i!=$SSH_SUM;i++ )); do
ssh -p $MT_SSH_PORT $Mikrotik_Login@$Mikrotik_IP "${CMD}" > /dev/null
STATUS=$?
if [ $STATUS -ne 0 ]; then
sleep $SSH_INTERVAL
fi

done
break
fi

done
}

# Находим все микротики
DB_User=$(cat $Path_Config| grep  username | awk '{ gsub("<username>"," "); print }' | awk '{ gsub("</username>"," "); print }' | awk '{print $1}')
DB_Password=$(cat $Path_Config| grep  password | awk '{ gsub("<password>"," "); print }' | awk '{ gsub("</password>"," "); print }' | awk '{print $1}')

SQL=`mysql -D mikbill -u $DB_User -p$DB_Password -e "SELECT nasname, naslogin FROM radnas WHERE usessh=1 and (nastype='mikrotik' or nastype='HotSpot')" 2>/dev/null`
#SQL=${SQL:$17:${#SQL}}

NUM=0
for i in $SQL; do
SQL_Array[$NUM]=$i
let "NUM=NUM+1"
done


for((i=2;i!=NUM;i+=2))
do
Mikrotik_IP=${SQL_Array[$i]}
Mikrotik_Login=${SQL_Array[$i+1]}
SSH_UPLOAD
done




# wget https://github.com/mikbill/design/raw/master/paysystems/ipset_paysystems_mikrotik.sh
# Version 3
# By Oleg Vilkovsky
