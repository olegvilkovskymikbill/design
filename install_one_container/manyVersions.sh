#!/bin/bash
num=10
for(( i=0;i<num;i++ ))
do
  docker run --entrypoint "/daemon" \
  -p 80$i:80 -p 81$i:81 -p 444$i:444  -p 3306$i:3306 \
  -p 1812$i:1812 -p 1813$i:1813 -p 67$i:67 -p 68$i:68 \
  -v www_$i:/var/www/mikbill \
  -v configs_$i:/etc/ \
  -v logs_$i:/var/log/ \
  -v base_$i:/var/lib/mysql/ \
  --name mikbill_$i \
  -d mikbill/mikbill_one_battle
done
