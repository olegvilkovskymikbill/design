#!/bin/bash

file=interfaces

vlanMin=181
vlanMax=300
network=31

#echo "#!/bin/bash" >$file_2
#chmod +x $file_2
echo>$file
for ((i=$vlanMin; i<=$vlanMax; i++))
do
#echo "vlan$i">>$file

#echo "ifconfig_vlan$i=\"10.46.$network.251/24 vlan $i vlandev igb1\"">>$file
#let "network=network+1"

echo "ifconfig vlan$i create">>$file

done
