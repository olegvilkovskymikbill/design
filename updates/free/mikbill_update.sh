#!/bin/bash

echo "Start UPDATER SOFT!"

VERSION_UPD="8"
ARG1=$1

UPDATE_URL="http://pay.update.2x.mikbill.pro/"
UPDATE_FILE="mikbill.tar.gz"
UPDATE_FILE_CHECKSUM="mikbill_checksum"
UPDATE_VERSION_UPDATER="mikbill_rev_up"
UPDATE_VERSION_MIKBILL="mikbill_revision"
UPDATE_VERSION_MIKBILL_CURRENT="mikbill_current"
MIKBILL_CONTACT_MESSAGE="У вас закончились обновления вопросы на sales@mikbill.ru"
MIKBILL_PATH_LINUX="/var/www/mikbill"
MIKBILL_PATH_BSD="/usr/local/www/mikbill"
MIKBILL_PATH_LINUX_INST="/var/www"
MIKBILL_PATH_BSD_INST="/usr/local/www"
MIKBILL_LOG_UPDATE="mikbill_update.log"
MIKBILL_UPDATE_PROGRAMM="mikbill_update.sh"
MIKBILL_CURRENT_FILE_CHECKSUM="mikbill_checksum_current"

TEST="0"

UNAME=`which uname`
ARCH=`$UNAME -m`
SYSTEM=`$UNAME`
NULL=" >/dev/null"

APP_ECHO=`which echo`
APP_WGET=`which wget`
APP_GREP=`which grep`
APP_AWK=`which awk`
APP_CAT=`which cat`
APP_RM=`which rm`
APP_PHP=`which php`
APP_LSB_RELEASE="111"
APP_SED=`which sed`
APP_CHMOD=`which chmod`
APP_CHOWN=`which chown`
APP_TAR=`which tar`
APP_DATE=`which date`
APP_CP=`which cp`

SESS_PATH=$(php -i | grep session.save_path | awk '{ print $3 }')
if [[ $SESS_PATH == *"php"* ]]; then
  chmod 777 $SESS_PATH
fi

check_php_version () {
#Проверить версию PHP и изменить ссылку для загрузки
#подразумевается что уже система нормально установлена

case $SYSTEM in
Linux)
    PHPVER=`$APP_PHP -i|$APP_GREP PHP |$APP_GREP Version |$APP_AWK {'print $4'}|$APP_SED 's/\./ /g' |$APP_SED -n 1p |$APP_AWK {'print $2'}`
    ;;
FreeBSD)
    PHPVER=`$APP_PHP -i|$APP_GREP PHP |$APP_GREP Version |$APP_AWK '{print $4}'|$APP_SED 's/\./ /g' |$APP_SED -n 1p |$APP_AWK '{print $2}'`
    ;;
esac
}

control_version_updater () {
#Выполняем проверку и контроль версии программы обновлений

$APP_WGET -q  $UPDATE_URL$UPDATE_VERSION_UPDATER $NULL
if [ ! -f ./$UPDATE_VERSION_UPDATER ] ; then
echo "Connection error file $UPDATE_VERSION_UPDATER"
exit
fi

VERSION_UPDATER=`$APP_CAT ./$UPDATE_VERSION_UPDATER`

if [ $VERSION_UPDATER -ne $VERSION_UPD ];
then
    echo "Detect Update of UPDATER SOFT!"
    $APP_RM -f ./$MIKBILL_UPDATE_PROGRAMM $NULL
    $APP_WGET -q --user=$UPDATE_LOGIN --password="$UPDATE_PASSWORD" $UPDATE_URL$MIKBILL_UPDATE_PROGRAMM $NULL
    $APP_CHMOD a+x ./$MIKBILL_UPDATE_PROGRAMM
    echo "RUN new version UPDATER SOFT!"
    ./$MIKBILL_UPDATE_PROGRAMM
    echo "Update of UPDATER SOFT Success!"
    exit
fi
echo "NO Update detected for UPDATER SOFT"
}

control_version_mikbill () {
#Проверка версии MikBill
$APP_RM -f ./$UPDATE_VERSION_MIKBILL $NULL
$APP_WGET -q $UPDATE_URL$UPDATE_VERSION_MIKBILL $NULL

if [ ! -f ./$UPDATE_VERSION_MIKBILL ] ; then
echo "Connection error file $UPDATE_VERSION_MIKBILL"
exit
fi

VERSION_MIKBILL=`$APP_CAT ./$UPDATE_VERSION_MIKBILL`
VERSION_MIKBILL_CURRENT=`$APP_CAT ./$UPDATE_VERSION_MIKBILL_CURRENT`


if [ "$ARG1" != "" ]
then
 exit
fi

if [ -f ./$UPDATE_VERSION_MIKBILL_CURRENT ];
then
    if [ -f ./$MIKBILL_CURRENT_FILE_CHECKSUM ];
    then
	#вначала проверка на версию
        if [ $VERSION_MIKBILL -eq $VERSION_MIKBILL_CURRENT ];
	then
	    #загрузка контрольной суммы скачаного обновления
	    $APP_WGET -q $UPDATE_URL$UPDATE_FILE_CHECKSUM $NULL
	    if [ ! -f ./$UPDATE_FILE_CHECKSUM ] ; then
		echo "Connection error file $UPDATE_FILE_CHECKSUM"
		exit
	    fi
	    FILE_CHECKSUM=`$APP_CAT ./$UPDATE_FILE_CHECKSUM`
	    FILE_CHECKSUM_CURRENT=`$APP_CAT ./$MIKBILL_CURRENT_FILE_CHECKSUM`
	    #Проверка текущей мд5 и мд5 на сервере
	    if [ "$FILE_CHECKSUM_CURRENT" != "$FILE_CHECKSUM" ];
	    then
		#мд5 изменился требуется скачать обновление
		echo "Do reload Version MIkBiLL"
    	    else
    		#мд5 равны, обновление не требуется
		delete_downloaded_files
		echo "MikBiLl Version is UP to Date"
		exit
    	    fi
	else
	    echo "Have New Version MIkBiLL"
	fi
    else
	#Нет файла - нужно переобновить обязательно
	echo "Do reload Version MIkBiLL"
    fi
else
    $APP_CAT ./$UPDATE_VERSION_MIKBILL > ./$UPDATE_VERSION_MIKBILL_CURRENT
    echo "Version file not found"
    echo "Do current version file"
fi
}

control_cheksum_mikbill () {
#Проверка контрольной суммы скачаного обновления

$APP_WGET -q $UPDATE_URL$UPDATE_FILE_CHECKSUM $NULL
if [ ! -f ./$UPDATE_FILE_CHECKSUM ] ; then
echo "Connection error file $UPDATE_FILE_CHECKSUM"
exit
fi

FILE_CHECKSUM=`$APP_CAT ./$UPDATE_FILE_CHECKSUM`
$APP_WGET -q $UPDATE_URL$UPDATE_FILE $NULL
if [ ! -f ./$UPDATE_FILE ] ; then
echo "Connection error file $UPDATE_FILE"
exit

fi



case $SYSTEM in
Linux)
APP_MD5=`which md5sum`
DOWNLOAD_CHECKSUM=`$APP_MD5 ./$UPDATE_FILE|$APP_AWK {'print $1'}`
;;
FreeBSD)
APP_MD5=`which md5`
DOWNLOAD_CHECKSUM=`$APP_MD5 ./$UPDATE_FILE|$APP_AWK '{print $4}'`
;;
esac

if [ "$DOWNLOAD_CHECKSUM" != "$FILE_CHECKSUM" ];
then
    echo "Update file Checksumm error $MIKBILL_CONTACT_MESSAGE "
    exit
fi
#сохраним текущий мд5
echo $FILE_CHECKSUM > ./$MIKBILL_CURRENT_FILE_CHECKSUM
echo "Checksumm is OK!"
}

delete_downloaded_files () {
#Удаляет загружаемые файлы

$APP_RM -f ./$UPDATE_FILE $NULL
$APP_RM -f ./$UPDATE_FILE_CHECKSUM $NULL
$APP_RM -f ./$UPDATE_VERSION_UPDATER $NULL

$APP_RM -f ./mikbill.tar.gz.*
$APP_RM -f ./mikbill_checksum.*
$APP_RM -f ./mikbill_rev_up.*
$APP_RM -f ./mikbill_revision.*
$APP_RM -f ./mikbill_update.sh.*
$APP_RM -f ./index.php*

admin_list=(
admin/res/convert
admin/res/convert2
admin/res/convert3
admin/res/pma
admin/res/mon
admin/res/mon2
admin/res/message
admin/res/message_client
admin/res/stalkerportal
admin/res/iptvportal
admin/res/w.qiwi.ru
)

stat_list=(
stat/res/message
stat/res/player
stat/stat.swf
stat/liqpay.php
stat/onpay.php
stat/paymaster.php
stat/privat24.php
stat/pscb.php
stat/robokassa.php
stat/robokassa_result.php
stat/wqiwiru.php
stat/payment_systems.php
stat/data/lib/gettext.inc
stat/data/lib/gettext.php
stat/data/lib/streams.php
)

store_dir="/var/mikbill/disabled"
upd_dir=$(pwd)
MV=$(which mv)

cd ../../..
cur_dir="${PWD##*/}"
if [ "$cur_dir" == "mikbill" ]; then
	mikbill_dir=$(pwd)

	if [ ! -d $store_dir/admin ]; then
		mkdir -p $store_dir/admin
	fi
	
	if [ ! -d $store_dir/stat ]; then
		mkdir -p $store_dir/stat
	fi

	cd $mikbill_dir
	if [ -f stat/data/template/olson/css/images/ui-icons_d38f41_256x240.png ]; then
                $MV stat/data/template/olson/css/images/ui-icons_d38f41_256x240.png $store_dir/ui-icons_d38f41_256x240.png
       	fi

	for item in ${admin_list[*]}
	do
		if [ -d $item ]; then
			echo "move dir $mikbill_dir/$item to $store_dir/$item"
			if [ ! -d $store_dir/$item ]; then
				mkdir -p $store_dir/$item
			fi

			$MV $mikbill_dir/$item $store_dir/$item
		fi
		if [ -f $item ]; then
			echo "move file $mikbill_dir/$item to $store_dir/$item"
			$MV $mikbill_dir/$item $store_dir/$item
		fi

	done

	for item in ${stat_list[*]}
	do
		if [ -d $item ]; then
			echo "move dir $mikbill_dir/$item to $store_dir/$item"
			if [ ! -d $store_dir/$item ]; then
				mkdir -p $store_dir/$item
			fi
			$MV $mikbill_dir/$item $store_dir/$item
		fi
		if [ -f $item ]; then
			if [ ! -d "$store_dir/stat/data/lib" ]; then
				mkdir -p "$store_dir/stat/data/lib"
			fi
			echo "move file $mikbill_dir/$item to $store_dir/$item"
			$MV $mikbill_dir/$item $store_dir/$item
		fi

	done

	# return to update dir
	cd $upd_dir
fi

echo "Delete downloaded old files success!"
}

detect_linux () {
#Действия после определения Linux системы
APP_NETSTAT=`which netstat`
echo "Detect Linux System $ARCH"
if [ -d $MIKBILL_PATH_LINUX ];
then
    echo "MikBIll Path=$MIKBILL_PATH_LINUX"
else
    echo "Error MikBill Dir Not Found"
    TEST="1"
fi
}

detect_freebsd () {
#Действия после определения FreeBSD системы
APP_SOCKSTAT=`which sockstat`
echo "Detect FreeBSD System $ARCH"
if [ -d $MIKBILL_PATH_BSD ];
then
    echo "MikBIll Path=$MIKBILL_PATH_BSD"
else
    echo "Error MikBill Dir Not Found"
    TEST="1"
fi
}

do_actions_centos () {
#Делать действия для CentOS

if [ "$TEST"=="0" ];
then
    $APP_TAR xzf ./$UPDATE_FILE -C $MIKBILL_PATH_LINUX_INST
    $APP_CHOWN -R apache:apache $MIKBILL_PATH_LINUX
    do_rhel_reload
fi
IS_CENTOS_6=`$APP_CAT /etc/redhat-release|$APP_GREP 6.`
if [ "$IS_CENTOS_6"=="" ];
then
    echo "Detect CenteOS 5.x $ARCH";
else
    echo "Detect CentOS 6.x $ARCH";
fi
}

do_actions_gentoo () {
#Делать действия для Gentoo

echo "Detect Gentoo"
if [ "$TEST"=="0" ];
then
    $APP_TAR xzf ./$UPDATE_FILE -C $MIKBILL_PATH_LINUX_INST
    $APP_CHOWN -R apache:apache $MIKBILL_PATH_LINUX
    do_rhel_reload
fi
}

do_actions_ubuntu () {
#Делать действия для Ubuntu 

echo "Detect $DISTRIBUTOR $VERSION_UBUNTU $ARCH"
if [ "$TEST"=="0" ];
then
    $APP_TAR xzf ./$UPDATE_FILE -C $MIKBILL_PATH_LINUX_INST
    $APP_CHOWN -R www-data:www-data $MIKBILL_PATH_LINUX
    do_debian_reload
fi
}

do_actions_debian () {
#Делать действия для Debian

echo "Detect $DISTRIBUTOR $VERSION_UBUNTU $ARCH"
if [ "$TEST"=="0" ];
then
    $APP_TAR xzf ./$UPDATE_FILE -C $MIKBILL_PATH_LINUX_INST
    $APP_CHOWN -R www-data:www-data $MIKBILL_PATH_LINUX
    do_debian_reload
fi
}

do_actions_freebsd () {
#Делать действия для FreeBSD

if [ "$TEST"=="0" ];
then
    $APP_TAR xzf ./$UPDATE_FILE -C $MIKBILL_PATH_BSD_INST
    $APP_CHOWN -R www:www $MIKBILL_PATH_BSD
    do_bsd_reload
fi
}

check_gentoo () {
#проверка на Gentoo

if [ -f /etc/gentoo-release ];
then
    APP_LSB_RELEASE=""
fi
}

check_centos () {
#проверка на CentOS

if [ -f /etc/redhat-release ];
then
    APP_LSB_RELEASE=""
fi
}

do_final_actions () {
#Выполнить финальные действия

if [ "$TEST"=="0" ];
then
    $APP_CAT ./$UPDATE_VERSION_MIKBILL > ./$UPDATE_VERSION_MIKBILL_CURRENT
    echo "Update Success!"
else
    echo "Update Error $MIKBILL_CONTACT_MESSAGE"
fi
delete_downloaded_files
}

do_final_unknown_linux () {
#ФИнал для неизвестной OS
    delete_downloaded_files
    exit
}

do_rhel_reload () {

cd $MIKBILL_PATH_LINUX"/admin/sys/update"
./mb_sql_upd.sh >> ./mikbill_update.log

#Перезагрузка сервисов rhel like systems
/etc/init.d/radiusd stop $NULL
$APP_NETSTAT -nlp|$APP_GREP 2007
/etc/init.d/mikbill stop $NULL
sleep 1
/etc/init.d/mikbill start $NULL
/etc/init.d/radiusd start $NULL
sleep 1
$APP_NETSTAT -nlp|$APP_GREP 2007
}

do_debian_reload () {

cd $MIKBILL_PATH_LINUX"/admin/sys/update"
./mb_sql_upd.sh >> ./mikbill_update.log

#Перезагрузка сервисов debian
/etc/init.d/freeradius stop $NULL
$APP_NETSTAT -nlp|$APP_GREP 2007
/etc/init.d/mikbill stop $NULL
sleep 1
/etc/init.d/mikbill start $NULL
/etc/init.d/freeradius start $NULL
sleep 1
$APP_NETSTAT -nlp|$APP_GREP 2007
}

do_bsd_reload () {

cd $MIKBILL_PATH_BSD"/admin/sys/update"
./mb_sql_upd.sh >> ./mikbill_update.log

#Перезагрузка сервисов bsd
/usr/local/etc/rc.d/radiusd stop $NULL
$APP_SOCKSTAT -4l|$APP_GREP 2007
/usr/local/etc/rc.d/mikbill stop $NULL
sleep 1
/usr/local/etc/rc.d/mikbill start $NULL
/usr/local/etc/rc.d/radiusd start $NULL
sleep 1
$APP_SOCKSTAT -4l|$APP_GREP 2007
}

do_mbplatform () {
    # mbdash
    MBDASH_DIR="/var/mikbill/updates/mbplatform"
    UPD_URL="http://update.mikbill.ru:9424/mbplatform_updater.sh"
    if [ ! -d $MBDASH_DIR ]; then
	mkdir -p $MBDASH_DIR
    fi

    if [ ! -f $MBDASH_DIR/autoupdate ]; then
	echo 1 > $MBDASH_DIR/autoupdate
    fi

    MBDASH_UPDATE_ENABLED=$(cat $MBDASH_DIR/autoupdate)
    if [ "$MBDASH_UPDATE_ENABLED" = "1" ]; then
	if [ -f $MBDASH_DIR/mbplatform_updater.sh ]; then
		rm -f $MBDASH_DIR/mbplatform_updater.sh
	fi
	if [ ! -f $MBDASH_DIR/mbplatform_updater.sh ]; then
		wget -O mbplatform_updater.sh -q $UPD_URL
		if [ $? -ne 0 ]; then
			echo "Download  FAILED! please check DNS and connection to $UPD_URL"
			exit 0
		fi
		chmod +x mbplatform_updater.sh
		mv mbplatform_updater.sh $MBDASH_DIR
	fi

	/bin/bash $MBDASH_DIR/mbplatform_updater.sh
    fi
}

do_prerelease () {
        # pre-release updates
        PRE_DIR="/var/mikbill/updates/pre_release"
        UPD_URL="http://pay.current.2x.mikbill.pro"
        if [ ! -d $PRE_DIR ]; then
                mkdir -p $PRE_DIR
        fi

        FNAME="install_pre-release.sh"
        if [ ! -f $PRE_DIR/$FNAME ]; then
                wget -O $FNAME -q $UPD_URL/$FNAME
                chmod +x $FNAME
                # ставим новый
                mv $FNAME $PRE_DIR
       	else
                wget -O $FNAME -q $UPD_URL/$FNAME
                chmod +x $FNAME
                # удаляем старый
                rm -f $PRE_DIR/$FNAME
                # ставим новый
                mv $FNAME $PRE_DIR
       	fi

        FNAME="undo_pre-release.sh"
        if [ ! -f $PRE_DIR/$FNAME ]; then
                wget -O $FNAME -q $UPD_URL/$FNAME
                chmod +x $FNAME
                # ставим новый
                mv $FNAME $PRE_DIR
       	else
                wget -O $FNAME -q $UPD_URL/$FNAME
                chmod +x $FNAME
                # удаляем старый
                rm -f $PRE_DIR/$FNAME
                # ставим новый
                mv $FNAME $PRE_DIR
       	fi
}

delete_downloaded_files
check_php_version
control_version_updater
control_version_mikbill
control_cheksum_mikbill

if [ -f ./$UPDATE_FILE ];
then
    echo "Download Success!"

    case $SYSTEM in
    Linux)
        detect_linux
	check_gentoo
	check_centos

	if [ -z $APP_LSB_RELEASE ];
	then
    	    if [ -f /etc/gentoo-release ];
    	    then
		do_actions_gentoo
    	    else
        	if [ -f /etc/redhat-release ];
    		then
		    do_actions_centos
		else
    		    echo "Uknown Linux"
    		    echo "Stop Update"
    		    TEST="1"
    		    do_final_unknown_linux
    		fi
    	    fi
	else
	    APP_LSB_RELEASE=`which lsb_release`
	    DISTRIBUTOR=`$APP_LSB_RELEASE -a|$APP_GREP Distributor|$APP_AWK '{print $3}'`
	    VERSION_UBUNTU=`$APP_LSB_RELEASE -a|$APP_GREP Release|$APP_AWK '{print $2}'`
	    if [ "$DISTRIBUTOR"=="Ubuntu" ];
	    then
        	do_actions_ubuntu
	    fi
	    if [ "$DISTRIBUTOR"=="Debian" ];
	    then
        	do_actions_debian
	    fi
	fi
    ;;
    FreeBSD)
        detect_freebsd
        do_actions_freebsd
    ;;
    esac

    do_mbplatform
    do_prerelease
    do_final_actions
else
    echo "Update Don't Download $MIKBILL_CONTACT_MESSAGE"
fi
