#!/bin/bash
# Version 18
# wget https://github.com/mikbill/design/raw/master/backup/SYS_backup.sh
HOME_DIR=$(cd $(dirname $0)&& pwd)
source $HOME_DIR/SYS_backup.conf

echo "----------------$DATE $SERVER_NAME-----------------" >>$LOG
set $(wc -l $LOG);LOGSTART=$1
echo -e "Свободное место на диске \n" "$(df -h $HOME_DIR)" >>$LOG
#Создаем ссылку на лог в рабочем каталоге
if ! ([ -e $LOG_LINK ])then
{
ln -s $LOG $LOG_LINK
}
fi

if !([ -d "$PACH_FOR_BACKUP_TO_DISK" ])then
{
mkdir $PACH_FOR_BACKUP_TO_DISK
}
fi

if [ "$SEND_EMAIL" -ne 0 -o "$SEND_EMAIL_2" -ne 0 ];then
{
service $EMAIL_SERVICE start
}
fi
#----------------------------------------------
FUNC_EMAIL()
{
set $(wc -l $LOG);LOGEND=$1"p"
(echo "Subject:$SERVER_NAME"; sed -n  $LOGSTART,$LOGEND $LOG;) | sendmail -F "BACKUP" $EMAIL_TMP
echo "отправка письма на почту $EMAIL_TMP" >>$LOG
}

FUNC_RM_OLDFILES_WEBDISK()
{
find $PACH_FOR_WEBDISK/$DIR_BACKUP_FOR_WEBDISK -mtime +$LIFE_TIME_FILE_ON_WEBDISK |sort|xargs rm -f
STATUS=$?
if [ $STATUS -ne 0 ]
then
sleep 10
FUNC_RM_OLDFILES_WEBDISK
fi
}

FUNC_RM_FILE_WEBDISK()
{
rm -f $PACH_FOR_WEBDISK/$DIR_BACKUP_FOR_WEBDISK/$FILENAME
STATUS=$?
if [ $STATUS -ne 0 ]
then
sleep 10
FUNC_RM_FILE_WEBDISK
fi
}

FUNC_COPY_TO_WEBDISK()
{
if [ "$BACKUP_TO_WEBDISK" -ne 0 ];then
{
if !([ -e "$PACH_FOR_WEBDISK" ])then
{
echo "$PACH_FOR_WEBDISK каталог не найден, создание каталога" >>$LOG
mkdir $PACH_FOR_WEBDISK
}
fi

if ! ( mount -v | grep -q $PACH_FOR_WEBDISK ) then
if [ "$MOUNT_POINT" = "mega" ];then
megafs --disable-previews --config $MEGA_CONF $PACH_FOR_WEBDISK
else
mount -t davfs $MOUNT_POINT $PACH_FOR_WEBDISK
fi
fi

if ! ( mount -v | grep -q $PACH_FOR_WEBDISK ) then
{
echo "! Ошибка монтирование диска $MOUNT_POINT в $PACH_FOR_WEBDISK !" >>$LOG
}
else
{
if !([ -d "$PACH_FOR_WEBDISK/$DIR_BACKUP_FOR_WEBDISK" ])then
{
echo "Каталог $PACH_FOR_WEBDISK/$DIR_BACKUP_FOR_WEBDISK не существует или был удален. Создание каталога" >>$LOG
mkdir -p $PACH_FOR_WEBDISK/$DIR_BACKUP_FOR_WEBDISK
}
fi

#Удаляем самые старые файлы пока не хватит места для нового бекапа
if [ $FREESPACE_WEBDISK -ne 0 ];then
{
SIZEFILE=`du -sm $PACH_FOR_BACKUP_TO_DISK/$FILENAME | awk '{print$1}'`
let FREESPACE=`df -m | grep "$PACH_FOR_WEBDISK" | awk '{print $3}'`-$SIZEFILE
while [$FREESPACE<0]
do
find $PACH_FOR_WEBDISK/$DIR_BACKUP_FOR_WEBDISK -name "*.tar.gz" -and -type f | sort -r | tail -n1 | xargs -i rm '{}'
let FREESPACE=`df -m | grep "$PACH_FOR_WEBDISK" | awk '{print $3}'`-$SIZEFILE
done
}
fi

if [ "$MOUNT_POINT" = "mega" ];then
megaput --config=$MEGA_CONF --path /$DIR_BACKUP_FOR_WEBDISK/ $PACH_FOR_BACKUP_TO_DISK/$FILENAME
else

if [ "$ENCRYPTION" -ne 0 ]
then
gpg -o $PACH_FOR_WEBDISK/$DIR_BACKUP_FOR_WEBDISK/$FILENAME_WEBDISK.gpg --yes -e -r $ENCRYPTION_ID_USER $PACH_FOR_BACKUP_TO_DISK/$FILENAME
else
cp $PACH_FOR_BACKUP_TO_DISK/$FILENAME $PACH_FOR_WEBDISK/$DIR_BACKUP_FOR_WEBDISK/$FILENAME_WEBDISK 2>>$LOG
fi
STATUS=$?

fi

if [ $STATUS -ne 0 -a ! -e "$PACH_FOR_WEBDISK/$DIR_BACKUP_FOR_WEBDISK/$FILENAME_WEBDISK" ];then
echo "! Ошибка $STATUS создания файла $PACH_FOR_WEBDISK/$DIR_BACKUP_FOR_WEBDISK/$FILENAME_WEBDISK !" >>$LOG
else
echo "Файл $PACH_FOR_WEBDISK/$DIR_BACKUP_FOR_WEBDISK/$FILENAME_WEBDISK создан успешно" >>$LOG
fi
}
fi
}
fi
}
#----------------------------------------------
FILENAME="log*tar.gz*"
rm -f $PACH_FOR_BACKUP_TO_DISK/$FILENAME
if [ "$BACKUP_TO_WEBDISK" -ne 0 ]
then
FUNC_RM_FILE_WEBDISK

  if [ "$WEBDISK_ONE_FILE" -eq 0 ]
  then
    FUNC_RM_OLDFILES_WEBDISK
  fi

fi
# Yandex client--------------------------------
if [ "$BACKUP_TO_YANDEX_CLIENT" -ne 0 ]
then
  yandex-disk start >>$LOG
fi
#----------------------------------------------
if [ "$BACKUP_MYSQL" -ne 0 ]; then
{
if [ "$DB_USER" = "" ]
then
DB_USER=$(cat $PATH_MIKBILL'app/etc/config.xml'| grep  username | awk '{ gsub("<username>"," "); print }' | awk '{ gsub("</username>"," "); print }' | awk '{print $1}')
fi
if [ "$DB_PASSWORD" = "" ]
then
DB_PASSWORD=$(cat $PATH_MIKBILL'app/etc/config.xml'| grep  password | awk '{ gsub("<password>"," "); print }' | awk '{ gsub("</password>"," "); print }' | awk '{print $1}')
fi

FILENAME=sql-"$SERVER_NAME"-"$DATE".sql.gz

mysqldump --single-transaction -u $DB_USER -p$DB_PASSWORD $DB_NAME 2>/dev/null | gzip > $PACH_FOR_BACKUP_TO_DISK/$FILENAME

find $PACH_FOR_BACKUP_TO_DISK -mtime +$LIFE_TIME_FILE_ON_DISk |sort|xargs rm -f

echo "бекап $PACH_FOR_BACKUP_TO_DISK/$FILENAME создан успешно" >>$LOG

if [ "$WEBDISK_ONE_FILE" -ne 0 ]
then
FILENAME_WEBDISK=sql-"$SERVER_NAME".sql.gz
else
FILENAME_WEBDISK=$FILENAME
fi

FUNC_COPY_TO_WEBDISK
}
fi
#----------------------------------------------
if [ "$BACKUP_FILES" -ne 0 ];then
{

if !([ -e "$TAR_EXCLUDE_LIST" ])then
{
echo "Создание файла исключений для бекапа файлов $TAR_EXCLUDE_LIST "
touch $TAR_EXCLUDE_LIST
}
fi

if !([ -e "$TAR_INCLUDE_LIST" ])then
{
echo "! бекап файлов включен, но конфигарационный файл $TAR_INCLUDE_LIST не найден. Создание файла. Заполните его !" >>$LOG
touch $TAR_INCLUDE_LIST
}
else
{
FILENAME=files-"$SERVER_NAME"-"$DATE".tar.gz

tar -X $TAR_EXCLUDE_LIST -T $TAR_INCLUDE_LIST -czf $PACH_FOR_BACKUP_TO_DISK/$FILENAME 2>>$LOG
STATUS=$?

if [ $STATUS -ne 0 ];then
echo "! Ошибка создания архива $STATUS $PACH_FOR_BACKUP_TO_DISK/$FILENAME !" >>$LOG
else
echo "Архив $PACH_FOR_BACKUP_TO_DISK/$FILENAME создан успешно" >>$LOG
fi

if [ "$WEBDISK_ONE_FILE" -ne 0 ]
then
FILENAME_WEBDISK=files-"$SERVER_NAME".tar.gz
else
FILENAME_WEBDISK=$FILENAME
fi

FUNC_COPY_TO_WEBDISK
}
fi
}
fi
# Owncloud ------------------------------------
if [ "$BACKUP_TO_OWNCLOUD" -ne 0 ]
then
  owncloudcmd -u $Owncloud_login -p $Owncloud_pass $PACH_FOR_BACKUP_TO_DISK $Owncloud_address
fi
# DropBox -------------------------------------
if [ "$BACKUP_TO_DROPBOX" -ne 0 ]
then
  ~/dropbox.py start >>$LOG
fi
#----------------------------------------------
FUNC_TAR_DIFF()
{
#бекап предыдущей проверки
rm -f $DIFF_BACKUP
tar -czf $DIFF_BACKUP $FILENAME 2>>$LOG
if [ $? -ne 0 ];then
{
echo "Ошибка создания резервной копии каталога $DIFF_DIR_NEW" >>$LOG
}
fi
}

if [ "$DIFF_FILES" -ne 0 ];then
{
echo "----------Проверка DIFF...----------" >>$LOG
if !([ -e "$DIFF_INCLUDE_LIST" ])then
{
echo "! Проверка DIFF включена, но файл $DIFF_INCLUDE_LIST не найден !" >>$LOG
}
else
{
if [ `ls $DIFF_DIR_NEW | wc -l` -eq 0 ];then
{
echo "Каталог $DIFF_DIR_NEW пустой или не существует (копируются файлы для последующей проверки)" >>$LOG
rsync -rptgoq --exclude-from=$DIFF_EXCLUDE_LIST --files-from=$DIFF_INCLUDE_LIST / $DIFF_DIR_NEW
#Делаем резервную копию
FILENAME=$DIFF_DIR_NEW
FUNC_TAR_DIFF
}
else
{
rsync -rptgo $DIFF_DIR_NEW/* $DIFF_DIR_OLD
#Снапшот системы
rsync -rptgoq --delete --delete-excluded --exclude-from=$DIFF_EXCLUDE_LIST --files-from=$DIFF_INCLUDE_LIST / $DIFF_DIR_NEW
#Сравниваем
if diff -r $DIFF_DIR_OLD $DIFF_DIR_NEW >>$LOG;then
{
echo "Отличий нет" >>$LOG
#Если нет резервной копии, делаем
if !([ -e "$DIFF_BACKUP" ])then
FILENAME=$DIFF_DIR_NEW
FUNC_TAR_DIFF
fi
}
else
{
#Делаем резервную копию
FILENAME=$DIFF_DIR_NEW
FUNC_TAR_DIFF
#Делаем инкрементную копию файлов
rsync -rptgo --delete -b --backup-dir=$DIFF_DIR_TEMP $DIFF_DIR_NEW/* $DIFF_DIR_OLD
#Если есть измененные файлы делаем архив предыдущей версии
if ([ -d "$DIFF_DIR_TEMP" ])then
{
FILENAME=configs-"$SERVER_NAME"-"$DATE".tar.gz
tar -czf $PACH_FOR_BACKUP_TO_DISK/$FILENAME $DIFF_DIR_TEMP 2>>$LOG
STATUS=$?
if [ $STATUS -ne 0 ];then
echo "! Ошибка создания архива ($STATUS) $PACH_FOR_BACKUP_TO_DISK/$FILENAME из каталога $DIFF_DIR_OLD !" >>$LOG
else
echo "Архив $PACH_FOR_BACKUP_TO_DISK/$FILENAME каталога $DIFF_DIR_OLD создан успешно" >>$LOG
rm -rf $DIFF_DIR_TEMP
fi

if [ "$WEBDISK_ONE_FILE" -ne 0 ]
then
FILENAME_WEBDISK=configs-"$SERVER_NAME".tar.gz
else
FILENAME_WEBDISK=$FILENAME
fi

FUNC_COPY_TO_WEBDISK
}
else
{
echo "Изменения есть, но старые файлы изменены не были, архив создан не будет" >>$LOG
}
fi
#Отправляем на почту лог изменений
if [ "$SEND_EMAIL_2" -ne 0 ];then
{
EMAIL_TMP=$EMAIL_2
FUNC_EMAIL
}
fi

}
fi
}
fi
}
fi
#Удаляем временый каталог
rm -rf $DIFF_DIR_OLD
}
fi
#----------------------------------------------
if [ "$SEND_EMAIL" -ne 0 ];then
{
EMAIL_TMP=$EMAIL
FUNC_EMAIL
}
fi

if [ "$SEND_EMAIL" -ne 0 -o "$SEND_EMAIL_2" -ne 0 ];then
{
sleep 20
service $EMAIL_SERVICE stop
}
fi
#-----------------------------------------------
if [ "$BACKUP_TO_WEBDISK" -ne 0 ];then
{
echo -e "Свободное место на диске \n" "$(df -h $PACH_FOR_WEBDISK)" >>$LOG

FILENAME="log-"$DATE".tar.gz"
tar -czf $PACH_FOR_BACKUP_TO_DISK/$FILENAME $LOG

if [ "$WEBDISK_ONE_FILE" -ne 0 ]
then
FILENAME_WEBDISK=log.tar.gz
else
FILENAME_WEBDISK=$FILENAME
fi

FUNC_COPY_TO_WEBDISK

if [ "$UMOUNT_WEBDISK" -ne 0 ];then
{
umount -l $PACH_FOR_WEBDISK
}
fi
}
fi
#-----------------------------------------------
if [ "$LOG_IN_TERMINAL" -ne 0 ];then
{
set $(wc -l $LOG);LOGEND=$1"p"
sed -n  $LOGSTART,$LOGEND $LOG
}
fi

#END SCRIPT
