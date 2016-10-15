#!/bin/bash
HOME_DIR=$(cd $(dirname $0)&& pwd)
source $HOME_DIR/radiuscash_2.conf

echo "$DATE start" >>$LOG
if ! ([ -e $LOG_LINK ])
then
ln -s $LOG $LOG_LINK
fi

UPLOAD_ADD_IPOE (){
INQUIRY="SELECT local_mac FROM users WHERE uid=$i"
SQL=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "$INQUIRY" 2>/dev/null`
SQL=$(echo $SQL | awk '{print $2}')
if [[ $SQL != NULL ]]
then
echo "/tool user-manager user add customer=admin username=$SQL" >>$UPLOAD
else
echo "NULL in MAC uid $i" >>$LOG
fi
}

rm $UPLOAD
INQUIRY="SELECT MAX( uid ) FROM users"
MAX=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "$INQUIRY" 2>/dev/null`
MAX=${MAX:11:${#MAX}}

INQUIRY="SELECT uid FROM users WHERE credit >= ABS (deposit) and blocked=0"
SQL=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "$INQUIRY" 2>/dev/null`
SQL=${SQL:4:${#SQL}}

for i in $SQL; do
ARRAY_UID[$i]="1"
done

if ([ -e "$LIST" ])
then

i=0
while read LINE; do
ARRAY_OLD[$i]=$LINE
let i=i+1
done < $LIST

for (( i=0; i <= $MAX; i++ ))
do

if [[ ${ARRAY_UID[$i]} -ne ${ARRAY_OLD[$i]} ]]
then

if [[ ${ARRAY_UID[$i]} -eq 1 ]]
then
UPLOAD_ADD_IPOE
else
echo "/tool user-manager user remove $(echo $SQL | awk '{print $2}')" >>$UPLOAD
fi

fi

done

# Если файта LIST нет
else
for (( i=0; i <= $MAX; i++ ))
do
if [[ ${ARRAY_UID[$i]} -eq 1 ]]
then
UPLOAD_ADD_IPOE
fi
done

fi

if ([ -e "$UPLOAD" ])
then

echo "/tool user-manager user create-and-activate-profile profile=admin customer=admin numbers=[find]" >> $UPLOAD

i=$CONNECT_SUM
while [ $i -ne 0 ]
do
scp -P $USERMAN_SSH_PORT $UPLOAD $USERMAN_LOGIN@$USERMAN_IP:/
UPLOAD_STATUS=$?
if [ $UPLOAD_STATUS -ne 0 ]
then
let i=i-1
sleep $CONNECT_INTERVAL
else
i=0
fi
done

i=$CONNECT_SUM
CMD="/import file=$UPLOAD"
while [ $i -ne 0 ]
do
ssh -p $USERMAN_SSH_PORT $USERMAN_LOGIN@$USERMAN_IP "${CMD}" > /dev/null
APPLY_STATUS=$?
if [ $APPLY_STATUS -ne 0 ]
then
let i=i-1
echo "Apply ssh no connect" >>$LOG
sleep $CONNECT_INTERVAL
else
i=0
fi
done

if [[ $UPLOAD_STATUS -eq 0 && $APPLY_STATUS -eq 0 ]]
then

echo "ssh connect OK" >>$LOG
rm $LIST
for (( i=0; i <= $MAX; i++ ))
do

if [[ ${ARRAY_UID[$i]} -eq 1 ]]
then
echo "1" >> $LIST
else
echo "0" >> $LIST
fi

done

else
echo "ssh no connect" >>$LOG
fi

fi

# version 2
# wget https://github.com/mikbill/design/raw/master/radiuscash/radiuscash_2.sh
