!/bin/bash
ip ro del 0.0.0.0/1
ip ro del 128.0.0.0/1
ip="`ip ro|grep "dev tun1  "| awk '{print $1}'`"
ip ro add 104.20.13.48/32 via $ip
