#!/bin/bash
URL="https://github.com/mikbill/design/raw/master/radiuscash/radiuscash_2.sh"

NAME="$(basename $URL)"
rm -f $NAME
wget $URL
chmod +x $NAME

# wget https://github.com/mikbill/design/raw/master/install.sh

