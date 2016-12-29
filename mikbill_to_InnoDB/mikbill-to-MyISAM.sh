#!/bin/bash

USER="root"
PASSWORD=""
MYSQL="mysql -u$USER -p$PASSWORD "

echo "SELECT CONCAT('ALTER TABLE ',table_schema,'.',table_name,' ENGINE=MyISAM;')
FROM information_schema.tables
WHERE engine = 'InnoDB' AND table_schema = 'mikbill'" | $MYSQL > convert.sql
sed '1d' ./convert.sql > ./convert2.sql
$MYSQL < ./convert2.sql
