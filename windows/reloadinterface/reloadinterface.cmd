echo off
chcp 1251

echo Скрипт с расширением *.cmd запустить с правами администратора

echo Меняем "Ethernet" на название своей сетевой карты 
set network_interface=Ethernet

echo timeout - время ожидания в выключенном состоянии интерфейса
set timeout=10

echo dst_address - проверяемый IP/Домен
set dst_address=8.8.8.8

echo num_packet - количество отправляемых пакетов командой ping
set num_packet=5

:start 
echo Выключение сетевой карты %network_interface%
netsh interface set interface name=%network_interface% admin=disabled
TIMEOUT /T %timeout% /NOBREAK
echo Включение сетевой карты %network_interface%
netsh interface set interface name=%network_interface% admin=enabled
ping %dst_address% -n %num_packet%
goto start
