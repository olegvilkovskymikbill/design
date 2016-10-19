#!/bin/bash
HOME_DIR=$(cd $(dirname $0)&& pwd)
source $HOME_DIR/radiuscash_2.conf

if !([ -e "$HOME_DIR/radiuscash_2.lib" ])
then
wget https://github.com/mikbill/design/raw/master/radiuscash/radiuscash_2.lib
fi
source $HOME_DIR/radiuscash_2.lib

TIME=$(date +%s)

FUNC_LOG_LINC

rm $UPLOAD

MAX_UID

UID_TO_ARRAY_UID

if ([ -e "$LIST" ])
then
LIST_TO_ARRAY_OLD 

for (( i=0; i <= $MAX; i++ ))
do

if [[ ${ARRAY_UID[$i]} -ne ${ARRAY_OLD[$i]} ]]
then

if [[ ${ARRAY_UID[$i]} -eq 1 ]]
then
IPOE_ADD
else
IPOE_RM
fi

fi

done

# Если файта LIST нет
else
echo "/tool user-manager user remove [find]" > $UPLOAD

case "$RADIUS_TYPE" in
"hotspot") 
IPOE_ADD
;;
"ppp")
PPP_ADD
;;
esac

fi

if ([ -e "$UPLOAD" ])
then

echo "/tool user-manager user create-and-activate-profile profile=admin customer=admin numbers=[find]" >> $UPLOAD

UPLOAD_TO_MIKROTIK

if [[ $UPLOAD_STATUS -eq 0 && $APPLY_STATUS -eq 0 ]]
then
echo "ssh connect OK" >>$LOG
ARRAY_UID_TO_LIST
else
echo "ssh no connect" >>$LOG
fi

fi

# version 2
# wget https://github.com/mikbill/design/raw/master/radiuscash/radiuscash_2.sh
