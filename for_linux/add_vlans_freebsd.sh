#!/bin/bash

file=interfaces

vlanMin=181
vlanMax=300
network=31

echo>$file
for ((i=$vlanMin; i<=$vlanMax; i++))
do
# 1 активируем вланы в rc.conf
echo "vlan$i">>$file

# 2 прописываем подсети в rc.conf
#echo "ifconfig_vlan$i=\"10.46.$network.251/24 vlan $i vlandev igb1\"">>$file
#let "network=network+1"

# 3 запускаем вланы без перезагрузки
#echo "ifconfig vlan$i create">>$file

# 4 прописываем вланы в mpd.conf
#echo "create link template vlan$i common">>$file
#echo "set pppoe iface vlan$i">>$file
#echo "set link enable incoming">>$file
#echo >>$file
done
