<?php
//header("Content-type: text/plain");

$uid = null;

if(!isset($argv[1])) {
	die();
} else {
	$uid = (int)$argv[1];
}

$config_file='../../app/etc/config.xml';
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

$user=array();
$QUERY_GET_USER="SELECT user, deposit, credit, blocked FROM users WHERE uid={$uid}";
$sql = $db->prepare($QUERY_GET_USER); $sql->execute();
$req = $sql->fetchAll(PDO::FETCH_ASSOC);
if ($sql->rowCount() > 0) {
	foreach ($req as $eq) {
			$name_tmp=explode("-", $eq["user"]);
			$name = $name_tmp[0];
			//echo "update user: {$name}, uid: {$uid}";
			// deposit 
			$QUERY_UPDATE_DEPOSIT= "UPDATE users SET deposit={$eq["deposit"]} WHERE user like '{$name}-%'";
			// deposit + blocked
			//$QUERY_UPDATE_DEPOSIT= "UPDATE users SET deposit={$eq["deposit"]}, blocked={$eq["blocked"]} WHERE user like '{$name}-%'";
			// deposit + credit + blocked
			//$QUERY_UPDATE_DEPOSIT= "UPDATE users SET deposit={$eq["deposit"]}, credit={$eq["credit"]}, blocked={$eq["blocked"]} WHERE user like '{$name}-%'";
			$db->exec($QUERY_UPDATE_DEPOSIT);
	}
} else {
	//echo "No users found \n";
}
