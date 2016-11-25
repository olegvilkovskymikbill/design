#!/bin/bash
HOME_DIR=$(cd $(dirname $0)&& pwd)
source $HOME_DIR/radcash.conf
source $HOME_DIR/radcash.lib

FUNC_MAX_UID

echo $MAX_UID >$MAX_UID_FILE
