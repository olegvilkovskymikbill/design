#!/bin/bash
HOME_DIR=$(cd $(dirname $0)&& pwd)
source $HOME_DIR/radcash.conf
source $HOME_DIR/radcash.lib

FUNC_MAX_UID

echo "/tool user-manager user" >$UPLOAD
echo "remove [find]" >>$UPLOAD

UID_TO_SQL

if [ "$RADIUS_HOTSPOT" -ne 0 ]
then
FUNC_HOTSPOT
fi
