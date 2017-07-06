                                                                                                                                                                                                               153/153               100%#!/bin/bash
upload_server=https://mydomain.com
file=users_5zoMuYNFkS6T
HOME_DIR=$(cd $(dirname $0)&& pwd)
wget -O $HOME_DIR/users $upload_server/$file
