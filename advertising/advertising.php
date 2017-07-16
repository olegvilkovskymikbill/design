<?php
$file_name='/var/www/mikbill/admin/advertising_N2g5R0uPnsDp';

$config_file='/var/www/mikbill/admin/app/etc/config.xml';
if (file_exists($config_file)) {
    $xml = simplexml_load_file($config_file);
    $TIME_ZONE           = (string) $xml->parameters->timezone;
    $CONF_MYSQL_HOST     = (string) $xml->parameters->mysql->host;
    $CONF_MYSQL_USERNAME = (string) $xml->parameters->mysql->username;
    $CONF_MYSQL_PASSWORD = (string) $xml->parameters->mysql->password;
    $CONF_MYSQL_DBNAME   = (string) $xml->parameters->mysql->dbname;
} else {
    die("config not found");
}

if(isset($TIME_ZONE))
    date_default_timezone_set($TIME_ZONE);
else
    date_default_timezone_set('Europe/Kiev');

$db = new PDO( "mysql:host={$CONF_MYSQL_HOST};dbname={$CONF_MYSQL_DBNAME}", $CONF_MYSQL_USERNAME, $CONF_MYSQL_PASSWORD,
    array(PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES koi8r") );

$ip = array();

$SQL_ip="SELECT local_ip FROM users WHERE prim='reklama'";
$res = $db->query($SQL_ip, PDO::FETCH_LAZY);

foreach ($res as $s) {
    array_push ($ip,$s['local_ip']);
    array_push($ip, "\n");
}

file_put_contents($file_name, $ip);
