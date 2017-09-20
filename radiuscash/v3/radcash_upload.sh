#!/bin/bash
# $1-UPLOAD_FILE $2-CONNECT_INTERVAL $3-CONNECT_SUM $4-USERMAN_IP $5-$USERMAN_SSH_PORT $6-$USERMAN_LOGIN $7-$USERMAN_APPLY
for (( i=0;i!=$3;i++ )); do
    scp -P $5 $1 $6@$4:/
    STATUS=$?
    if [ $STATUS -ne 0 ]; then
            sleep $2
    else
	if [ $7 -ne 0 ]; then
	    CMD="/import file=$(basename $5)"
	    for (( i=0;i!=$3;i++ )); do
		ssh -p $5 $6@$4 "${CMD}" > /dev/null
		STATUS=$?
		if [ $STATUS -ne 0 ]
	    	    then
	    	    sleep $2
		else
	    	    exit
		fi
	    done
        fi
    fi
done                                                                                                    