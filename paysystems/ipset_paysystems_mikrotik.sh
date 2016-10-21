#!/bin/bash
#͑Client DNS
DNS1=91.224.16.1
DNS2=91.224.16.2
# Mikrotik
MT_IP="192.168.10.67"
MT_SSH_PORT="22"
MT_LOGIN="mikbill"
SSH_INTERVAL=10
SSH_SUM=10

DIG=`which dig`
IPSET=`which ipset`
IPSETNAME="paysystems"

HOME_DIR=$(cd $(dirname $0)&& pwd)
SRCDATA=`cat $HOME_DIR/domains.list`
IPLIST="$HOME_DIR/ip.list"
RESULT="$HOME_DIR/paysys.txt"
UPLOAD=$HOME_DIR/upload_paysys.rsc

$DIG +short $SRCDATA @$DNS1 |grep '\([[:digit:]]\{1,3\}\.\)\{3\}[[:digit:]]\{1,3\}' > $RESULT
$DIG +short $SRCDATA @$DNS2 |grep '\([[:digit:]]\{1,3\}\.\)\{3\}[[:digit:]]\{1,3\}' >> $RESULT
cat $IPLIST >> $RESULT

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
# Version 1
# By Oleg Vilkovsky
