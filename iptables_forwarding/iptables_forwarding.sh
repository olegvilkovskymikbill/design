#!/bin/bash

# Вшний IP роутера
EXT_R_IP=

# Внутренний "фэйковый" адрес машины, которую надо "выкидывать" наружу
LOCAL_IP=

# Порт, на который будут заходить извне и попадать на локальную машину
PORT1=

# Порт, который "выбрасывается" наружу(например, 80 - http, либо 21 - ftp)
PORT2=

iptables -t nat -A PREROUTING -p tcp -d $EXT_R_IP --dport $PORT1 -j DNAT --to-destination $LOCAL_IP:$PORT2
iptables -A FORWARD -i eth0 -d $LOCAL_IP -p tcp --dport $PORT2 -j ACCEPT


# Просмотр правил
# iptables -t nat -L -n -v -x
# С номерами
# iptables -L FORWARD -n --line-numbers
# Удаляем по номеру
# iptables -D FORWARD 3

# Включаем forward 
# nano /etc/sysctl.conf 
# net.ipv4.ip_forward = 1
# Применяем
# sysctl -p
