#!/bin/bash

file=interfaces

vlanMin=3500
vlanMax=3700
first=eth4.

for ((i=$vlanMin; i<=$vlanMax; i++))
do
echo >>$file
echo "auto $first$i">>$file                                               
echo "  iface $first$i inet manual">>$file                                
echo '  post-up ifconfig $IFACE up'>>$file                                
echo '  pre-down ifconfig $IFACE down'>>$file                             
done
