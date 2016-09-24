#!/bin/bash
if [ "$(which php)" != "" ] ; then
file=modules_in_system
modules=( bcmath bz2 calendar Core ctype curl date iconv imap json dom ereg exif fileinfo filter ftp gd gettext
 gmp hash libxml mbstring mysql mysqli openssl pcntl pcre PDO pdo_mysql Phar posix pspell readline recode
 Reflection session shmop SimpleXML snmp soap sockets SPL standard sysvmsg sysvsem sysvshm tokenizer wddx
 xml xmlreader xmlrpc xmlwriter xsl zip zlib )
php -m>$file
missed=0
for item in "${modules[@]}"; do
if ! grep -q -w "$item" modules_in_system ; then
echo -e "$item \e[31m no module \e[0m"
let "missed=1"
fi
done
if [ "$missed" -eq "0" ];then
echo -e "\e[33m modules OK \e[0m"
fi
rm -f $file
else
echo -e "\e[31m php not installed \e[0m"
fi
