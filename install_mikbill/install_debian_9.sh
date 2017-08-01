#!/bin/bash

TERM=linux

DIRINST=`pwd`
ip_billing="10.10.1.1"
domain_billing="ispnet.demo"
mysql_root_passwd="paaswd"
mysql_mikbill_passwd="passwd"
start_opt=$DIRINST/start_opt
logfile=$DIRINST/log_install

echo ""> $logfile

log(){
   message="$(date +"%y-%m-%d %T") - $@"
   echo $message >>$logfile
}


DEBIAN_FRONTEND=noninteractive apt-get install -y dialog  >> log_install

echo "10" | dialog --gauge "Please wait" 10 70 0


export DEBIAN_FRONTEND=noninteractive

function set_start_opt {

dialog --separate-widget $'\n' --ok-label "Next" --backtitle "" --title "" --form "" 20 80 10 \
        "IP - адрес:"               1 5 "$ip_billing"             1 33 36 15 \
        "Доменное имя:"             2 5 "$domain_billing "        2 33 36 0 \
        "MySQL - root password:"    3 5 "$mysql_root_passwd"      3 33 36 0 \
        "MySQL - mikbill password:" 4 5 "$mysql_mikbill_passwd"   4 33 36 0 \
2>&1 1>&4 | {
        read -r ip_billing
        read -r domain_billing
        read -r mysql_root_passwd
        read -r mysql_mikbill_passwd
        echo $ip_billing>$start_opt
        echo $domain_billing>>$start_opt
        echo $mysql_root_passwd>>$start_opt
        echo $mysql_mikbill_passwd>>$start_opt
}

}


exec 4>&1

again=yes

while [ "$again" = "yes" ]
do
    set_start_opt
    ip_billing=`sed -n 1,1p $start_opt`
    if [[ $ip_billing =~ ^[1-9][0-9]{0,2}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
 dialog --yesno "            Значения все введены верно?" 5 50
 respose=$?
 case $respose in
     0)
  again=no
  ;;
     1)
  again=yes
  ;;
     255)
  again=no
 esac
    else
 dialog --msgbox "Неправильный IP" 5 50
    fi
done

exec 4>&-

ip_billing=`sed -n 1,1p $start_opt`
domain_billing=`sed -n 2,2p $start_opt`
mysql_root_passwd=`sed -n 3,3p $start_opt`
mysql_mikbill_passwd=`sed -n 4,4p $start_opt`

log "Clear iptables"

iptables -F
iptables -X


echo "15" | dialog --gauge "Please wait" 10 70 0


log "Install packets"

apt-get -q -y install mc screen mrtg dhcp3-server libio-socket-inet6-perl bind9 dnsutils ntpdate rcconf >> log_install

echo "20" | dialog --gauge "Please wait" 10 70 0

apt-get -q -y install ntp bash mc tcpdump iptraf  pciutils sudo links iptables-persistent lynx mrtg >> log_install

echo "25" | dialog --gauge "Please wait" 10 70 0

apt-get -q -y install nginx  >> log_install

apt-get -q -y install mysql-server >> log_install

echo "30" | dialog --gauge "Please wait" 10 70 0


log "pear -q channel-discover pear.phing.info"
pear -q channel-discover pear.phing.info >/dev/null
log "pear -q upgrade-all"
pear -q upgrade-all >/dev/null

echo "60" | dialog --gauge "Please wait" 10 70 0

log "pear -q install phing/phing"
pear -q install phing/phing >/dev/null


log "cp -R ./etc/php5/conf.d/*  /etc/php5/conf.d"
cp -R ./etc/php5/conf.d/*  /etc/php5/conf.d

log "cp -R ./etc/php5/fpm/pool.d/* /etc/php5/fpm/pool.d"
cp -R ./etc/php5/fpm/pool.d/* /etc/php5/fpm/pool.d


log "mkdir mikbill"
if [ ! -d /var/www ];
then
    mkdir /var/www
    mkdir /var/www/mikbill
elif [ ! -d /var/www/mikbill ];
then
    mkdir /var/www/mikbill
fi

ARCH=`uname -m`
# ZEND
log "cp -R ./zendGL_x64/ZendGuardLoader.so /usr/lib/php5/"
if [ "$ARCH" == "x86_64" ];
then
cp -R ./zendGL_x64/ZendGuardLoader.so /usr/lib/php5/
else
cp -R ./zendGL_x86/ZendGuardLoader.so /usr/lib/php5/
fi
# ZEND end

echo "70" | dialog --gauge "Please wait" 10 70 0

OUTPUTDIR="/var/www/mikbill"

log "tar xzf ../system/admin.tar.gz"
tar xzf ../system/admin.tar.gz -C $OUTPUTDIR
log "tar xzf ../system/stat.tar.gz"
tar xzf ../system/stat.tar.gz -C $OUTPUTDIR
log "tar xzf ../system/map.tar.gz"
tar xzf ../system/map.tar.gz -C $OUTPUTDIR

log "cp -rf ../php5.4/* /var/www/mikbill/"
cp -rf ../php5.4/* /var/www/mikbill/ 2> /dev/null
log "chown -R www-data:www-data $OUTPUTDIR"
chown -R www-data:www-data $OUTPUTDIR

log "mkdir /etc/mrtg"
if [ ! -d /etc/mrtg ];
then
    mkdir /etc/mrtg
fi


log "echo > /etc/mrtg/mrtg_mikbill_users.conf"
echo > /etc/mrtg/mrtg_mikbill_users.conf
log "echo > /etc/mrtg/mrtg_mikbill_tarif.conf"
echo > /etc/mrtg/mrtg_mikbill_tarif.conf

log "chmod -R a+rw /etc/mrtg"
chmod -R a+rw /etc/mrtg


log "cp -R ./etc/crontab /etc/"
cp -R ./etc/crontab /etc/

if  ! grep -q "www-data ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
log "echo www-data ALL=(ALL) NOPASSWD:ALL>> /etc/sudoers"
echo "www-data ALL=(ALL) NOPASSWD:ALL">> /etc/sudoers
fi

log "cp -R ./usr/local/sbin/* /usr/local/sbin/"
cp -R ./usr/local/sbin/* /usr/local/sbin/
log "cp -R ./etc/logrotate.d/* /etc/logrotate.d/"
cp -R ./etc/logrotate.d/* /etc/logrotate.d/

log "rm -rf /etc/freeradius"
rm -rf /etc/freeradius
log "rm /etc/init.d/freeradius"
rm /etc/init.d/freeradius
log "rm -rf /etc/rc3.d/S20freeradius"
rm -rf /etc/rc3.d/S20freeradius



log "cp -R ./etc/freeradius  /etc/"
cp -R ./etc/freeradius  /etc/

log "cp -R ./etc/init.d/*  /etc/init.d/"
cp -R ./etc/init.d/*  /etc/init.d/


log "cp /etc/freeradius/serialize.pm /usr/lib/perl5"
cp /etc/freeradius/serialize.pm /usr/lib/perl5

MYSQLADMIN=`which mysqladmin`
$MYSQLADMIN -u root password "$mysql_root_passwd" &>/dev/null

log "Insert password in admin,stat,map,freeradius"
sed -i "s/MIKBILLPASS/$mysql_mikbill_passwd/g" /etc/freeradius/sql.conf
sed -i "s/MIKBILLPASS/$mysql_mikbill_passwd/g" /var/www/mikbill/admin/app/etc/config.xml
sed -i "s/MIKBILLPASS/$mysql_mikbill_passwd/g" /var/www/mikbill/stat/app/etc/config.xml
sed -i "s/MIKBILLPASS/$mysql_mikbill_passwd/g" /var/www/mikbill/map/app/etc/config.xml

log "rm -rf /etc/nginx/conf.d"
rm -rf /etc/nginx/conf.d

if [ ! -d /etc/nginx/conf.d ];
then
    mkdir /etc/nginx/conf.d
    mkdir /etc/nginx/conf.d/ssl
fi

echo "75" | dialog --gauge "Please wait" 10 70 0


log "Create opessl certificate"
openssl req -new -newkey rsa:1024 -nodes -keyout /etc/nginx/conf.d/ssl/ca.key -x509 -days 500 -subj /C=UA/ST=Kiev/L=Kiev/O=Companyname/OU=User/CN=etc/emailAddress=admin@my_site.com -out /etc/nginx/conf.d/ssl/ca.crt 2> /dev/null


log "Copy nginx configs files"
cp -R ./etc/nginx/* /etc/nginx/



log "Edit nginx files"
sed -i "s/ispnet\.demo/$domain_billing/g" /etc/nginx/conf.d/00_stat_zaglushka_vhost.conf
sed -i "s/ispnet\.demo/$domain_billing/g" /etc/nginx/conf.d/admin_vhost.conf
sed -i "s/ispnet\.demo/$domain_billing/g" /etc/nginx/conf.d/stat_vhost.conf
sed -i "s/ispnet\.demo/$domain_billing/g" /etc/nginx/conf.d/map_vhost.conf
sed -i "s/ip_billing/$ip_billing/g" /etc/nginx/conf.d/admin_vhost.conf

log "chmod a+rw /etc/dhcp/"
chmod a+rw /etc/dhcp/

log "chmod a+rw /etc/dhcp/dhcpd.conf"
chmod a+rw /etc/dhcp/dhcpd.conf

log "Remove mikbill,freeradius,apache2 from rc.d"
update-rc.d -f mikbill remove 1>/dev/null
update-rc.d -f freeradius remove 1>/dev/null
update-rc.d -f apache2 remove 1>/dev/null

if [ -f /etc/init.d/tntnet ];
then
    update-rc.d -f tntnet remove &>/dev/null
    /etc/init.d/tntnet stop &>/dev/null
fi

log "Add in rc.d mikbill,freeradius"
sudo update-rc.d mikbill defaults 80
sudo update-rc.d freeradius defaults 87

log "iptables-save >/etc/iptables/rules.v4"
iptables-save >/etc/iptables/rules.v4


log "Remove freeradius dictionary"
rm -rf /usr/share/freeradius/dictionary
rm -rf /usr/share/freeradius/dictionary.mpd
rm -rf /usr/share/freeradius/dictionary.mikrotik

log "Copy freeradius dictionary"
cp -R ./usr/share/freeradius/dictionary /usr/share/freeradius/
cp -R ./usr/share/freeradius/dictionary.mpd /usr/share/freeradius/
cp -R ./usr/share/freeradius/dictionary.mikrotik /usr/share/freeradius/
cp -R ./usr/share/freeradius/dictionary.dlink /usr/share/freeradius/
cp -R ./usr/share/freeradius/dictionary.dhcp /usr/share/freeradius/

ginfo=`grep -c "ntpdate" /etc/rc.local`


log "Configure system time"
if [[ $ginfo -eq "0" ]]; then
 sed -i '/exit/d' /etc/rc.local
 echo '/usr/sbin/ntpdate pool.ntp.org > /dev/null' >> /etc/rc.local
 echo '' >> /etc/rc.local
 echo 'exit 0' >> /etc/rc.local
 echo '' >> /etc/rc.local
fi

echo "80" | dialog --gauge "Please wait" 10 70 0


MYSQL=`which mysql`
MYSQLUPD=`which mysql_upgrade`
$MYSQLUPD -uroot -p$mysql_root_passwd &>/dev/null

log "Create mikbill database"
sed -e "s/MIKBILLPASS/$mysql_mikbill_passwd/g" ../sql/install/mikbill_5.5.sql > ../sql/install/mikbill_5.5.sql2
$MYSQL -uroot -p$mysql_root_passwd < ../sql/install/mikbill_5.5.sql2 &> /dev/null
rm -rf ../sql/install/mikbill_5.5.sql2
$MYSQL -uroot -p$mysql_root_passwd mikbill < ../sql/2.0.6/mikbill_2_0_6_utf8.sql &> /dev/null


log "Configure sysctl.conf"
ginfo=`grep -c "disable_ipv6" /etc/rc.local`
if [[ $ginfo -eq "0" ]]; then
 sed -i '/disable_ipv6/d' /etc/sysctl.conf
 echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
 echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf
 echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.conf
fi

echo "85" | dialog --gauge "Please wait" 10 70 0


log "Run mb_sql_upd.sh"
cd /var/www/mikbill/admin/sys/update
./mb_sql_upd.sh &>/dev/null

echo "90" | dialog --gauge "Please wait" 10 70 0


####NOT FOUND FILE!!!!!
cd ..
log "Run update.sh"
cd ../update/mikbill_update
./update.sh &>/dev/null


echo "100" | dialog --gauge "Please wait" 10 70 0


/etc/init.d/freeradius stop >/dev/null
/etc/init.d/mikbill stop >/dev/null
/etc/init.d/mysql restart >/dev/null
/etc/init.d/mikbill start >/dev/null
/etc/init.d/freeradius start >/dev/null
/etc/init.d/php5-fpm restart >/dev/null
/etc/init.d/nginx restart >/dev/null


dialog --tailbox --title "Log install" log_install

dialog --clear  --title "Install Mikbill" --msgbox "\n\n
Обязательно заполните их в админке для правильной работы системы \n
\n
Параметры для системных опций->системные пути: \n
\n
sudo      =    `which sudo` -u root \n
TC        =    `which tc` \n
IP        =    `which ip` \n
grep      =    `which grep` \n
awk       =    `which awk` \n
SSH       =    `which ssh` \n
ARP       =    `which arp` \n
Ethers    =    /etc/ethers \n
Cisco     =    /opt/freeradius/sbin/clrline \n
portslave =    /usr/bin/finger \n
PPPd      =    /usr/local/sbin/pppkill \n
RadClient =    `which radclient` \n
echo      =    `which echo` \n
Radiusd   =    /etc/init.d/freeradius restart \n
Mysqld    =    /etc/init.d/mysql restart \n
SNMPWalk  =    `which snmpwalk` \n
 \n\n
Запишите сдедующие данные:\n
\n
Админка:             https://admin.$domain_billing\n
Админка по IP:       https://$ip_billing\n
Личный кабинет:      https://stat.$domain_billing\n
Карта:               https://map.$domain_billing\n
\n
Сертификат самоподписанный\n
\n
Пароль root на MySql:                 $mysql_root_passwd\n
Пароль пользователя mikbill на Mysql: $mysql_mikbill_passwd\n
\n
Для доступа в админку - admin\admin\n
\n
Не забываем настроить часовой пояс в OS      - это ОЧЕНЬ важно\n
Не забываем настроить часовой пояс в php.ini - это ОЧЕНЬ важно\n
Не забываем настроить часовой пояс в mikbill - это ОЧЕНЬ важно\n
" 50 80

##################################
cp /etc/freeradius/serialize.pm /etc/perl/
