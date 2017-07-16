<?php
$ip_remote = $_GET['ip_remote'];
$ipsetname='advertising';
$command="sudo /sbin/ipset -D $ipsetname $ip_remote";
exec($command." &>/dev/null 2>&1");
?>
