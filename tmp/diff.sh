#!/bin/bash
#
# Directory comparison by Oleg Vilkovsky

HOME_DIR=$(cd $(dirname $0)&& pwd)
#DIR1=$HOME_DIR/files/test1
#DIR2=$HOME_DIR/files/test2
DIR1=$HOME_DIR/files/centos1
DIR2=$HOME_DIR/files/centos2


DIROUTPUT1=$HOME_DIR/files/output1
DIROUTPUT2=$HOME_DIR/files/output2
DIROUTPUT3=$HOME_DIR/files/output3

DIFF1=$HOME_DIR/dirdiff_1.txt
DIFF2=$HOME_DIR/dirdiff_2.txt

DEL1=$HOME_DIR/del1.txt
DEL2=$HOME_DIR/del2.txt
DIFF=$HOME_DIR/diff.txt

log=$HOME_DIR/log


#rsync --recursive --delete --links --checksum --verbose --dry-run $DIR1/ $DIR2/ 2>&1 | awk -F' ' '/deleting/ {print $2}' > dirdiff_1.txt
#rsync --recursive --delete --links --checksum --verbose --dry-run $DIR2/ $DIR1/ 2>&1 | awk -F' ' '/deleting/ {print $2}' > dirdiff_2.txt
#diff --brief --recursive --no-dereference --new-file --no-ignore-file-name-case $DIR1 $DIR2 > dirdiff_1.txt


# Получаем списки с отличиями
function get_lists_of_differences() {
rsync --recursive --delete --links --checksum --verbose --dry-run $DIR1/ $DIR2/ > $DIFF1
rsync --recursive --delete --links --checksum --verbose --dry-run $DIR2/ $DIR1/ > $DIFF2

# Удаляем шапку и статистику
sed -i '1d' dirdiff_1.txt
sed -i '1d' dirdiff_2.txt

sed -i '$ d' dirdiff_1.txt
sed -i '$ d' dirdiff_1.txt

sed -i '$ d' dirdiff_2.txt
sed -i '$ d' dirdiff_2.txt


# Получаем списки файлов, которые есть только в одном из каталогов
cat $DIFF1 | awk -F' ' '/deleting/ {print $2}' > $DEL1
cat $DIFF2 | awk -F' ' '/deleting/ {print $2}' > $DEL2
}

get_lists_of_differences

 
function set_diroutput1() {
# Собираем каталог 1

if [ -d $DIROUTPUT1 ]; then
rm -r $DIROUTPUT1
fi

cp -R $DIR1 $DIROUTPUT1

if [ -f "$DIFF" ]; then
rm -f $DIFF
fi

# Получаем список отличающихся файлов
while read LINE
    do 
    #echo $LINE
    #grep -w $LINE $DIFF2 |wc -l
    
    if grep -xq "$LINE" $DIFF2; then
      echo $LINE >>$DIFF
#echo 1
    fi
    done < $DIFF1

sed -i '/^[[:space:]]*skipping/d' diff.txt
sed -i '$ d' $DIFF

while read LINE
do
  rm -rf $DIROUTPUT1/$LINE
done < $DEL2

while read LINE
do
#  echo $LINE
  rm -f $DIROUTPUT1/$LINE
done < $DIFF
}
set_diroutput1

function set_diroutput2() {
# Собираем каталог 2
if [ -d "$DIROUTPUT2" ]; then
rm -rf $DIROUTPUT2
fi
mkdir $DIROUTPUT2

while read LINE
do
# mkdir -p "$DIROUTPUT2/$LINE" && cp -rf "$DIR1/$LINE"
 # echo "$DIR1/$LINE $DIROUTPUT2" >>$log
#echo $LINE
newdir=$(dirname $LINE)
mkdir -p $DIROUTPUT2/$newdir
#echo $newdir >>1 

# mkdir -p $dirname
  cp "$DIR1/$LINE" $DIROUTPUT2/$newdir/
  #cp -rf "$DIR1/$LINE" $DIROUTPUT2
done < $DEL2

while read LINE
do
newdir=$(dirname $LINE)
mkdir -p $DIROUTPUT2/$newdir
  cp -rf "$DIR1/$LINE" $DIROUTPUT2/$newdir/
done < $DIFF
}
set_diroutput2
 
function set_diroutput3() {
# Собираем каталог 3
if [ -d "$DIROUTPUT3" ]; then
rm -rf $DIROUTPUT3
fi


mkdir $DIROUTPUT3
while read LINE
do
newdir=$(dirname $LINE)
mkdir -p $DIROUTPUT3/$newdir
cp -rf "$DIR2/$LINE" $DIROUTPUT3/$newdir/
done < $DEL1
        
while read LINE
do
newdir=$(dirname $LINE)
mkdir -p $DIROUTPUT3/$newdir
  cp -rf "$DIR2/$LINE" $DIROUTPUT3/$newdir/
done < $DIFF
      
}

set_diroutput3

    
    
    
    
    