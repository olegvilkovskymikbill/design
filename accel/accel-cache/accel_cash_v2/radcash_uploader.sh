                                                                                                                                                                                                               153/153               100%#!/bin/bash
upload_server=https://mydomain.com
file=users_5zoMuYNFkS6T

# Указываем минимальный размер скачиваемого файла
# Нужно для проверки, чтобы при проблемах закачки файл не перезаписался
size=349603

HOME_DIR=$(cd $(dirname $0)&& pwd)
wget -O $HOME_DIR/$file $upload_server/$file --no-check-certificate

size_tmp=$(stat $file -c %s)
#echo $size_tmp
if [ "$size_tmp" -gt "$size" ]; then
$(cp -f $file users)
fi
