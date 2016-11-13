#!/bin/bash
HOME_DIR=$(cd $(dirname $0)&& pwd)
source $HOME_DIR/radcash.conf
source $HOME_DIR/radcash.lib

ID=$1

FUNC_CHECK_ID

if [ "$CHECK_ID" != "" ]
then

echo >$UPLOAD
echo "/tool user-manager user" >>$UPLOAD

if [ "$RADIUS_HOTSPOT" -ne 0 ]
then
FUNC_HOTSPOT_ID
fi

if [ "$RADIUS_PPP" -ne 0 ]
then
FUNC_PPP_ID
fi

SSH_UPLOAD

fi
