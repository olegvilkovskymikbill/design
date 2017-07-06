#!/bin/bash

Radtest="/usr/bin/radtest"

Radius_server_IP="20.20.20.20"
Radius_secret="secret"

Accel_conf=/etc/accel-ppp.conf
#log=/var/log/mikbill.log
Date=`date +%Y-%m-%d_%Hh%Mm`

mrad="server=20.20.20.20,secret,auth-port=1812,acct-port=1813,req-limit=0,fail-time=0"
lrad="server=127.0.0.1,testing123,auth-port=1812,acct-port=1813,req-limit=0,fail-time=0"


HOME_DIR=$(cd $(dirname $0)&& pwd)
log=$HOME_DIR/log
filestatus=$HOME_DIR/status
mikbill=2
source $filestatus


Status=$(${Radtest} dsjkdjskdrewrwe tefdfsfsdfsdfsdf3st $Radius_server_IP 121123 $Radius_secret) > /dev/null

if ! [[ "$Status" =~ packet ]]; then
    if [ $mikbill -ne 0 ];then
        echo "$Date Start radius-cash">$log
        sed -i "s/$mrad/$lrad/g" $Accel_conf
        echo "mikbill=0">$filestatus
        /etc/init.d/freeradius restart
        accel-cmd reload
    fi
else
    if [ $mikbill -ne 1 ];then
        echo "$Date Start mikbill-radius">$log
        sed -i "s/$lrad/$mrad/g" $Accel_conf
        echo "mikbill=1">$filestatus
        accel-cmd reload
    fi
fi
