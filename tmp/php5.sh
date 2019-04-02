wget http://download.suhosin.org/suhosin-0.9.33.tgz --no-check-certificate
tar -xvf suhosin-0.9.33.tgz
cd suhosin-0.9.33
phpize
./configure
make
make install
echo 'extension=suhosin.so' > /etc/php.d/suhosin.ini
