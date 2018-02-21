#!/bin/bash

file=interfaces
file_2=vlans_no_reboot.sh

vlanMin=3500
vlanMax=3700
first=eth4.

echo "#!/bin/bash" >$file_2
chmod +x $file_2                      
                                          
for ((i=$vlanMin; i<=$vlanMax; i++))      
do                                        
echo >>$file                              
echo "auto $first$i">>$file
echo "  iface $first$i inet manual">>$file
echo '  post-up ifconfig $IFACE up'>>$file
echo '  pre-down ifconfig $IFACE down'>>$file

echo "/sbin/vconfig add $first $i" >>$file_2
echo "/sbin/ifconfig $first.$i up" >>$file_2

done
