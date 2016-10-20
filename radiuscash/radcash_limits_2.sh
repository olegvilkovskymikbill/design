#!/bin/bash
HOME_DIR=$(cd $(dirname $0)&& pwd)
source $HOME_DIR/radiuscash_2.conf

if !([ -e "$HOME_DIR/radiuscash.lib" ])
then
wget https://github.com/mikbill/design/raw/master/radiuscash/radiuscash.lib
fi
source $HOME_DIR/radiuscash.lib
