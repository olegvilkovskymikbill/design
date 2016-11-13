#!/bin/bash
HOME_DIR=$(cd $(dirname $0)&& pwd)
source $HOME_DIR/radcash.conf
source $HOME_DIR/radcash.lib

echo >$UPLOAD
echo "/tool user-manager user" >>$UPLOAD

UID=$1
echo $UID >>UPLOAD
