#!/usr/bin/expect -f
    spawn openvpn vpnbook-euro1-tcp443.ovpn
    #spawn ssh aspen
    set password [lindex $argv 1]
    expect "Enter Auth Username:"
    send "vpnbook\r"
    expect "Enter Auth Password:"
    send "sun2ymf\r";
    interact

spawn /home/zmayo/vpnbook_route.sh
