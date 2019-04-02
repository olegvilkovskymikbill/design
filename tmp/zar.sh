#!/bin/bash

FILES=(
/var/www/mikbill/stat/data/lib/new_js.php
/var/www/mikbill/stat/app/log/daily_draws.png
/var/www/mikbill/stat/app/log/monthly_draws.png
/var/www/mikbill/admin/res/fsb/css/plugins/datapicker/main.php
/var/www/mikbill/admin/res/fsb/css/plugins/datapicker/index.php
/var/www/mikbill/stat/sys/user_null/uid_null-2week.png
/var/www/mikbill/stat/data/template/olson/font/fontawesome-webfontb31e.eot
/var/www/mikbill/stat/data/template/olson/font/fontawesome-webfontd94d.eot
)

for ITEM in ${FILES[*]}
do
	if [ -f "$ITEM" ]; then
		echo "suspicious file: $ITEM"
	fi
done

find /var/www/mikbill/ -type f \( ! -name "*.log" -and ! -name "*.gz" -and ! -name "*.so" \) -exec grep -H 'file_get_contents(.font_xpattr)' {} \;
find /var/www/mikbill/ -type f \( ! -name "*.log" -and ! -name "*.gz" -and ! -name "*.so" -and ! -name "*.js" \) -exec grep -H '], .black_list' {} \;
find /var/www/mikbill/ -type f \( ! -name "*.log" -and ! -name "*.gz" -and ! -name "*.so" -and ! -name "*.js" \) -exec grep -H 'eval(' {} \;
