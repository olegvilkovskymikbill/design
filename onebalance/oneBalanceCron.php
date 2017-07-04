<?php
header("Content-type: text/plain");

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

$users_list=array();
$QUERY_GET_USERS="SELECT uid, user FROM users WHERE user LIKE '%-%'";
$sql = $db->prepare($QUERY_GET_USERS); $sql->execute();
$res = $sql->fetchAll(PDO::FETCH_ASSOC);
if ($sql->rowCount() > 0) {
	foreach ($res as $value) {
		$name_tmp=explode("-", $value["user"]);
		$name = $name_tmp[0];

		$QUERY_GET_USER="SELECT uid, deposit, credit, blocked FROM users WHERE user LIKE '{$name}' AND user NOT LIKE '{$name}-%'";
		$sql = $db->prepare($QUERY_GET_USER); $sql->execute();
		$req = $sql->fetchAll(PDO::FETCH_ASSOC);
		if ($sql->rowCount() > 0) {
			foreach ($req as $eq) {
				$users_list[$name]["uid"] = $eq["uid"];
				$users_list[$name]["deposit"] = $eq["deposit"];
				$users_list[$name]["credit"] = $eq["credit"];
				$users_list[$name]["blocked"] = $eq["blocked"];
			}
		}
	}

	foreach ($users_list as $user=>$value) {
		if(isset($value["uid"])) {
				//echo "update user: {$user}, uid: {$value["uid"]}";
				// deposit 
				$QUERY_UPDATE_DEPOSIT= "UPDATE users SET deposit={$value["deposit"]} WHERE user like '{$user}-%'";
				// deposit + blocked
			    //$QUERY_UPDATE_DEPOSIT= "UPDATE users SET deposit={$value["deposit"]}, blocked={$value["blocked"]} WHERE user like '{$user}-%'";
				// deposit + credit + blocked
				//$QUERY_UPDATE_DEPOSIT= "UPDATE users SET deposit={$value["deposit"]}, credit={$value["credit"]}, blocked={$value["blocked"]} WHERE user like '{$user}-%'";
				$db->exec($QUERY_UPDATE_DEPOSIT);
		} else {
			//echo "main user not found \n";
		}
	}
} else {
	//echo "No users found \n";
}
