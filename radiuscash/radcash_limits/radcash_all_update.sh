#!/bin/bash
HOME_DIR=$(cd $(dirname $0)&& pwd)
./limits_update.sh
sleep 10
./radcash.sh
