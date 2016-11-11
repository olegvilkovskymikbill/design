#!/bin/bash
HOME_DIR=$(cd $(dirname $0)&& pwd)
source $HOME_DIR/radcash.conf
source $HOME_DIR/radcash.lib

FUNC_MAX_UID

echo >$UPLOAD

if [ "$LOG_REMOVE" -ne 0 ]
then
echo "/tool user-manager log remove numbers=[find]" >>$UPLOAD
fi

echo "/tool user-manager user" >>$UPLOAD
echo "remove [find]" >>$UPLOAD

UID_TO_USERS

if [ "$RADIUS_HOTSPOT" -ne 0 ]
then
FUNC_HOTSPOT
fi

if [ "$RADIUS_PPP" -ne 0 ]
then
FUNC_PPP
fi

SSH_UPLOAD
