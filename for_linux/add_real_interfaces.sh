#!/bin/bash

file=interfaces

ip=213.174.7.
min=65
max=94

n=1
for ((i=$min; i<=$max; i++))
do
echo >>$file

echo "auto lo:$n">>$file
echo "   iface lo:$n inet static">>$file
echo "   address $ip$i">>$file
echo "   netmask 255.255.255.255">>$file

let "n=n+1"

done
