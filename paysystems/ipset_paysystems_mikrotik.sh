#!/bin/bash
#Client DNS
DNS1=192.168.10.1
DNS2=8.8.8.8
# Mikrotik
MT_IP="192.168.10.1"
MT_SSH_PORT="22"
MT_LOGIN="bill"
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

echo "/ip firewall address-list remove [/ip firewall address-list find list=$ADDRESS_LIST]" >$UPLOAD

touch $TMP
for i in $RESULT; do
if ! grep -q $i $TMP
then
echo "/ip firewall address-list add list="$ADDRESS_LIST" address=$i" >>$UPLOAD
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
ssh -p $MT_SSH_PORT $MT_LOGIN@$MT_IP "${CMD}" > /dev/null
STATUS=$?
if [ $STATUS -ne 0 ]; then
sleep $SSH_INTERVAL
fi

done
break
fi

done
}
SSH_UPLOAD

# wget https://github.com/mikbill/design/raw/master/paysystems/ipset_paysystems_mikrotik.sh
# Version 2
# By Oleg Vilkovsky
