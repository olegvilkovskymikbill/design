echo off
chcp 1251

echo Ńęđčďň ń đŕńřčđĺíčĺě *.cmd çŕďóńňčňü ń ďđŕâŕěč ŕäěčíčńňđŕňîđŕ

echo Ěĺí˙ĺě "Ethernet" íŕ íŕçâŕíčĺ ńâîĺé ńĺňĺâîé ęŕđňű 
set network_interface=Ethernet

echo timeout - âđĺě˙ îćčäŕíč˙ â âűęëţ÷ĺííîě ńîńňî˙íčč číňĺđôĺéńŕ
set timeout=10

echo dst_address - ďđîâĺđ˙ĺěűé IP/Äîěĺí
set dst_address=8.8.8.8

echo num_packet - ęîëč÷ĺńňâî îňďđŕâë˙ĺěűő ďŕęĺňîâ ęîěŕíäîé ping
set num_packet=5

:start
echo Âűęëţ÷ĺíčĺ ńĺňĺâîé ęŕđňű %network_interface%
netsh interface set interface name=%network_interface% admin=disabled

 
TIMEOUT /T %timeout% /NOBREAK
echo Âęëţ÷ĺíčĺ ńĺňĺâîé ęŕđňű %network_interface%
netsh interface set interface name=%network_interface% admin=enabled
ping %dst_address% -n %num_packet%
goto start
