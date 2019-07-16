#!/bin/bash
FILE1=du.txt
FILE2=du2.txt
while read LINE1 ;do
  array1=($(echo $LINE1 | tr " " "\n"))
  key1=${array1[1]}
  while read LINE2 ;do
    array2=($(echo $LINE2 | tr " " "\n"))
    key2=${array2[1]}
    if [ "$key1" = "$key2" ] ;then
      value1=${array1[0]}
      value2=${array2[0]}
      let "diff=value2-value1"
      if [ "$diff" != "0" ] ;then
        echo "$key1 $diff"
#      else
#        echo "$key1 OK"
      fi
      break
    fi
  done < $FILE2
done < $FILE1
