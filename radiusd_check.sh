#!/bin/bash

Path_mikbill="/var/www/mikbill/admin"
Log="/var/log/mikbill.log"

Radtest=$(which radtest)
Script=$(readlink -f $0)

Func_log (){
echo "$Script: $1" >>$Log
}

Find_radius (){
if [ $(which radiusd) ]
then
    Radius="radiusd"
    else
    if [ $(which freeradius) ]
    then
<------>Radius="freeradius"
<------>else
<------>Func_log "Radius not found"
<------>exit
    fi
fi
}

Radius_restart (){
/etc/init.d/$Radius stop
sleep 1
cd $Path_mikbill
/usr/bin/php index.php clear_online
/etc/init.d/$Radius start
Func_log "Radius restarting"
}

Test_radius (){
Radius_server_IP="127.0.0.1"
Radius_secret="testing123"

Status=$(${Radtest} dsjkdjskdrewrwe tefdfsfsdfsdfsdf3st $Radius_server_IP 121123 $Radius_secret) > /dev/null.
if ! [[ "$Status" =~ packet ]]; then
Find_radius
Radius_restart
fi

}

Find_radtest (){
if [ $(which radtest) ]
then
    Radtest=$(which radtest)
    else
    if ([ -e "/usr/local/bin/radtest" ])
    then
<------>Radtest="/usr/local/bin/radtest"
<------>else
<------>Script_name
<------>Func_log "Radtest not found"
<------>exit
    fi
fi

}

Check_MySQL (){
if [[ $(netstat -nl|grep 3306)<'1' ]]
then
    Func_log "MySQL not started, try run"
    /etc/init.d/mysqld start
    sleep 1
    if [[ $(netstat -nl|grep 3306)>'0' ]]
    then
    Func_log "MySQL Started"
    else
    Func_log "MySQL started error"
    exit
 fi
fi
}

Check_MySQL
Find_radtest
Test_radius

# nano /etc/crontab
# # Check radius
# */1 * * * * root /var/www/mikbill/admin/sys/scripts/radiusd_check.sh > /dev/null 2>&1
