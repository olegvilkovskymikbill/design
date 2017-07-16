#!/bin/bash

upload_server=https://admin.myserver.com
file=advertising_N2g5R0uPnsDp
HOME_DIR=$(cd $(dirname $0)&& pwd)
wget -O $HOME_DIR/$file $upload_server/$file

ipsetname="advertising"

ipset -N $ipsetname iphash -exist
ipset --flush $ipsetname
#ipset --flush advertising

while read LINE
    do
#echo $LINE
ipset add $ipsetname $LINE -exist 2>/dev/null;
done < $HOME_DIR/$file

#ipset -L advertising
