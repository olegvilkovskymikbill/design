#!/bin/bash

USER="root"
PASSWORD=""
MYSQL="mysql -u$USER -p$PASSWORD "

echo "SELECT CONCAT('ALTER TABLE ',table_schema,'.',table_name,' ENGINE=InnoDB;')
FROM information_schema.tables
WHERE engine = 'MyISAM' AND table_schema = 'mikbill'" | $MYSQL > convert3.sql
sed '1d' ./convert3.sql > ./convert4.sql
$MYSQL < ./convert4.sql
