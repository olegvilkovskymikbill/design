#!/bin/bash
#͑Client DNS
DNS1=91.224.16.1
DNS2=91.224.16.2

DIG=`which dig`
IPSET=`which ipset`
IPSETNAME="paysystems"

HOME_DIR=$(cd $(dirname $0)&& pwd)
SRCDATA=`cat $HOME_DIR/domens.list`
IPLIST="$HOME_DIR/ip.list"
RESULT="$HOME_DIR/paysys.txt"

$DIG +short $SRCDATA @$DNS1 |grep '\([[:digit:]]\{1,3\}\.\)\{3\}[[:digit:]]\{1,3\}' > $RESULT
$DIG +short $SRCDATA @$DNS2 |grep '\([[:digit:]]\{1,3\}\.\)\{3\}[[:digit:]]\{1,3\}' >> $RESULT
cat $IPLIST >> $RESULT

$IPSET -N $IPSETNAME iphash -exist
for i in `cat $RESULT`;
do
$IPSET add $IPSETNAME $i -exist 2>/dev/null;
done
