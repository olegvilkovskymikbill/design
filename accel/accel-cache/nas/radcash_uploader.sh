#!/bin/bash
upload_server=https://mydomain.com
file=users_111111111
HOME_DIR=$(cd $(dirname $0)&& pwd)
wget -O $HOME_DIR/users $upload_server/$file
