#!/bin/bash

if ["$1" = ""]
then
    while(true)
    do
    clear
    accel-cmd show sessions
    sleep 1
    done
else
    while(true)
    do
    clear
    accel-cmd show sessions|grep $1
    sleep 1
    done

fi
