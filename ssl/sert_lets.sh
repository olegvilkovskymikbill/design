#!/bin/bash

# Админка
admin=
# Личный кабинет
stat=
# Карты
map=

path_mikbill=/var/www/mikbill/
path_ssl=/etc/nginx/conf.d/ssl

yum -y install nc wget socat
wget -O - https://get.acme.sh | sh

function add_domain(){
if ! [[ -z $1 ]]; then
/root/.acme.sh/acme.sh --issue -d $1 -w $path_mikbill/$2
cp ~/.acme.sh/$1/fullchain.cer $path_ssl/$1.cer
cp ~/.acme.sh/$1/$1.key $path_ssl/$1.key
echo "Add to conf $1:"
echo -e "\033[0;35mssl_certificate $path_ssl/$1.cer; \033[0m"
echo -e "\033[0;35mssl_certificate_key $path_ssl/$1.key; \033[0m"
echo "Add to cron $1"
echo -e "\033[0;35m00 05 * * * root /root/.acme.sh/acme.sh --renew -d $1  \033[0m"
echo -e "\033[0;35m10 05 * * * root /etc/init.d/nginx restart \033[0m"
fi
}

add_domain $admin admin
add_domain $stat stat
add_domain $map map
