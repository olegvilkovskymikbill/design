#!/bin/bash

ipaddr=10.10.10.
HostMin=65
HostMax=94
filename=alias.sh
echo>$filename

i=$HostMin
n=0
echo "#!/bin/bash">$filename
for ((i=$HostMin; i<=$HostMax; i++))
do
echo "ifconfig lo:$n $ipaddr$i  netmask 255.255.255.255" >>$filename
let "n=n+1"
done
chmod +x $filename

echo "Add to /etc/rc.local:"
echo "#aliases for NAT"
echo "/etc/network/$filename"
