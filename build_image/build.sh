#!/bin/bash
name="mikbill/mysql"

HOME_DIR=$(cd $(dirname $0)&& pwd)
docker build -t $name $HOME_DIR

