#!/bin/bash

STATS="/var/log/radius_test.log"
RADTEST="/usr/bin/radtest"
#RADTEST=$(which radtest)


FREERAD_SRV_IP="127.0.0.1"
FREERAD_SECRET="testing123"

${RADTEST} dsjkdjskdrewrwe tefdfsfsdfsdfsdf3st $FREERAD_SRV_IP 121123 $FREERAD_SECRET > $STATS

TEST=`tail ${STATS}| /usr/bin/awk "/$1/ { result=\\$3 } END { print result ?  result : 0 }"`

if [ "$TEST" == "packet" ];
then
#    echo "radiusd OK "
exit
else
#    echo "radiusd stoped, restarting"
    /etc/init.d/radiusd stop
    sleep 1
    cd /var/www/mikbill/admin
    /usr/bin/php index.php clear_online
    /etc/init.d/radiusd start
fi

# nano /etc/crontab
# # Check radius
# */1 * * * * root /var/www/mikbill/admin/sys/scripts/radiusd_check.sh > /dev/null 2>&1
