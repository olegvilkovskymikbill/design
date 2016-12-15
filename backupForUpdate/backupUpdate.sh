#!/bin/bash

MIKBILL_CONFIG="admin/app/etc/config.xml"
MIKBILL_DIR="/var/www/mikbill"
WORK_PATH="/var/mikbill"
BACKUP_DIR="old_version"
BACKUP_SQL="sql_backup"

RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

NULL="> /dev/null 2>&1"
GREP=`which grep`
AWK=`which awk`
PHP=`which php`
SED=`which sed`
CP=`which cp`
RM=`which rm`
TAR=`which tar`
GZIP=`which gzip`
MKDIR=`which mkdir`
BASH=`which bash`
NTPDATE=`which ntpdate`
MYSQLDUMP=`which mysqldump`
CHOWN=`which chown`
WGET=`which wget`
WEB_OWNER=`stat -c '%U' $MIKBILL_DIR`

PHPVER=`$PHP -i|$GREP PHP |$GREP Version |$AWK {'print $4'}|$SED 's/\./ /g' |$SED -n 1p |$AWK {'print $2'}`
URL="https://demo2x.mikbill.ru/5.$PHPVER.tar.gz"
TIME_SERVER="pool.ntp.org"

check_directories() {
	echo " "
	echo "Checking directories:"

	# working folder
	if [ ! -d "$WORK_PATH" ]; then
		echo "Creating $WORK_PATH"
		$MKDIR $WORK_PATH
	else
		echo "Working directory found"
    fi

	# update folder
	if [ -d "$WORK_PATH/5.$PHPVER" ]; then
        echo "Clearing update folder"
		$RM -rf $WORK_PATH/5.$PHPVER/*
		$RM -f $WORK_PATH/5.$PHPVER.tar.gz
    fi

	# backup folder
	if [ ! -d "$WORK_PATH/$BACKUP_DIR" ]; then
		echo "Creating $WORK_PATH/$BACKUP_DIR"
		$MKDIR $WORK_PATH/$BACKUP_DIR
	else
		echo "Clearing backup folder"
		$RM -rf $WORK_PATH/$BACKUP_DIR/*
	fi
	echo " "
}

update() {
	cd $WORK_PATH
	echo "Downloading update"
	$WGET -q $URL

	if [ $? -ne 0 ]; then
		echo "Download FAILED! please check DNS and connection to mikbill.ru"
		exit 0
	fi

	echo "extracting update"
	$TAR zxf 5.$PHPVER.tar.gz

	echo "sync time"
	$NTPDATE -u $TIME_SERVER
	echo " "

	echo "copy update"
	$CHOWN $WEB_OWNER:$WEB_OWNER -R $WORK_PATH/5.$PHPVER/
	$CP -fRH $WORK_PATH/5.$PHPVER/* $MIKBILL_DIR/
	echo " "
}

update_sql() {
	echo "update SQL"
	cd $MIKBILL_DIR/admin/sys/update/
	$BASH mb_sql_upd.sh
	echo " "
}

backup_files() {
	echo "backup admin & stat files"
	$CP -fR $MIKBILL_DIR/admin $WORK_PATH/$BACKUP_DIR/
	$CP -fR $MIKBILL_DIR/stat $WORK_PATH/$BACKUP_DIR/
	echo " "
}

backup_sql() {
	echo "backup sql"
	data=`cat $MIKBILL_DIR/$MIKBILL_CONFIG`
	host=$(grep -oPm1 "(?<=<host>)[^<]+" <<< "$data")
	username=$(grep -oPm1 "(?<=<username>)[^<]+" <<< "$data")
	password=$(grep -oPm1 "(?<=<password>)[^<]+" <<< "$data")
	database=$(grep -oPm1 "(?<=<dbname>)[^<]+" <<< "$data")
	$MYSQLDUMP -h $host -u $username -p$password $database | $GZIP > $WORK_PATH/$BACKUP_DIR/$BACKUP_SQL.sql.gz
	echo " "
}

restart_service() {
	echo " "
	echo -e " ${GREEN}Update END${NC}"
	echo -e " ${GREEN}Need restart mikbill & radius${NC}"
	echo " "
	echo -e " ${CYAN}Dont forget remove update archive from mikbill server:${NC}"
	echo -e " ${RED}rm /var/www/demo/demo2x/5.$PHPVER.tar.gz${NC}"
}

echo " "
echo -e "${CYAN}Before install, copy current update on mikbill server to demo2x folder:${NC}"
echo -e "${RED}cp cur_ver/5.$PHPVER.tar.gz /var/www/demo/demo2x/${NC}"
echo " "

PS3='Select update method: '
options=("Update" "Update +Files" "Update +Database" "Update +Files +Database" "Quit")
select opt in "${options[@]}"
do
    case $opt in
		"Update")
			check_directories
			update
			update_sql
			restart_service
			break
			;;
		"Update +Files")
			check_directories
			backup_files
			update
			update_sql
			restart_service
			break
			;;
		"Update +Database")
			check_directories
			backup_sql
			update
			update_sql
			restart_service
			break
			;;
		"Update +Files +Database")
			check_directories
			backup_files
			backup_sql
			update
			update_sql
			restart_service
			break
			;;
		"Quit")
			break
			;;
        *) echo invalid option;;
    esac
done
