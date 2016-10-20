#!/bin/bash
HOME_DIR=$(cd $(dirname $0)&& pwd)
source $HOME_DIR/radcash.conf

echo "/tool user-manager user remove [find]" > $UPLOAD

if [ "$RADIUS_HOTSPOT" -ne 0 ]
then
INQUIRY="SELECT local_mac FROM users WHERE credit >= ABS (deposit) and blocked=0"
SQL=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "$INQUIRY" 2>/dev/null`
SQL=${SQL:10:${#SQL}}
for i in $SQL; do
if [[ $i != NULL && $i != "" ]]
then
echo "/tool user-manager user add customer=admin username=$i" >>$UPLOAD
fi
done
fi

if [ "$RADIUS_PPP" -ne 0 ]
then
INQUIRY="SELECT user, password FROM users WHERE credit >= ABS (deposit) and blocked=0;"
SQL=`mysql -D $DB_NAME -u $DB_USER -p$DB_PASSWORD -e "$INQUIRY" 2>/dev/null`
SQL=${SQL:14:${#SQL}}

NUM=0
for i in $SQL; do
LOGIN_PASS[$NUM]=$i
let "NUM=NUM+1"
done

for((i=0;i!=NUM;i+=2))
do
echo "/tool user-manager user add customer=admin username=${LOGIN_PASS[$i]} password=${LOGIN_PASS[$i+1]}" >>$UPLOAD
done
fi


echo "/tool user-manager user create-and-activate-profile profile=admin customer=admin numbers=[find]" >>$UPLOAD
#SSH
for (( i=0;i!=10;i++ )); do

scp -P $USERMAN_SSH_PORT $UPLOAD $USERMAN_LOGIN@$USERMAN_IP:/
STATUS=$?
if [ $STATUS -ne 0 ]; then
sleep 10
else

CMD="/import file=$(basename $UPLOAD)"
for (( i=0;i!=10;i++ )); do
ssh -p $USERMAN_SSH_PORT $USERMAN_LOGIN@$USERMAN_IP "${CMD}" > /dev/null
STATUS=$?
if [ $STATUS -ne 0 ]; then
sleep 10
fi

done
break
fi

done

# version 1.2
# tested mikrotik 6.34.1
# wget https://github.com/mikbill/design/raw/master/radiuscash/radiuscash.sh
# ssh-keygen
