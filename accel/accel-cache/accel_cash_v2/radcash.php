<?php
$file_name='/var/www/mikbill/admin/users_5zoMuYNFkS6T';
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

function mask2cidr($mask){
    $long = ip2long($mask);
    $base = ip2long('255.255.255.255');
    return 32-log(($long ^ $base)+1,2);
}

if(isset($TIME_ZONE))
    date_default_timezone_set($TIME_ZONE);
else
    date_default_timezone_set('Europe/Kiev');

$db = new PDO( "mysql:host={$CONF_MYSQL_HOST};dbname={$CONF_MYSQL_DBNAME}", $CONF_MYSQL_USERNAME, $CONF_MYSQL_PASSWORD,
    array(PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES koi8r") );


$network = array();
$users = array();
$speed = array();
$text = array();

$SQL_segment="SELECT sectorid, subnet, mask, routers FROM sectors WHERE routers != ''";
$res = $db->query($SQL_segment, PDO::FETCH_LAZY);
foreach ($res as $s) {
	$network[$s["sectorid"]]["subnet"] = $s["subnet"];
	$network[$s["sectorid"]]["mask"] = $s["mask"];
	$network[$s["sectorid"]]["gateway"] = $s["routers"];
}

$SQL_speed="SELECT gid, speed_rate, speed_burst, do_shapers FROM packets";
$res = $db->query($SQL_speed, PDO::FETCH_LAZY);
foreach ($res as $p) {
	if ( $p["do_shapers"] == 1) {
			$speed[$p["gid"]]["in"] = $p["speed_rate"];
			$speed[$p["gid"]]["out"] = $p["speed_burst"];
	} else {
			$speed[$p["gid"]]["in"] = 0;
			$speed[$p["gid"]]["out"] = 0;
	}

}

$SQL_users="SELECT u.uid, u.gid, u.user, u.password, u.framed_ip, u.local_ip, u.local_mac, u.sectorid, u.real_ip, u.speed_rate, u.speed_burst
			FROM users u, packets p 
			WHERE u.credit+u.deposit >= 0-p.razresh_minus AND u.blocked=0 AND u.gid = p.gid";
$res = $db->query($SQL_users, PDO::FETCH_LAZY);
foreach ($res as $u) {
	$users[$u["uid"]]["login"] = $u["user"];
	$users[$u["uid"]]["password"] = $u["password"];
	$users[$u["uid"]]["mac"] = $u["local_mac"];
	$users[$u["uid"]]["real_ip"] = $u["real_ip"];
	if ( $u["real_ip"] == 1 ) {
			$users[$u["uid"]]["ip"] = $u["framed_ip"];
	} else {
			$users[$u["uid"]]["ip"] = $u["local_ip"];
	}
	$users[$u["uid"]]["fip"] = $u["framed_ip"];
	$users[$u["uid"]]["mask"] = mask2cidr($network[$u["sectorid"]]["mask"]);
	$users[$u["uid"]]["gateway"] = $network[$u["sectorid"]]["gateway"];
	if ( $u["speed_rate"] != 0 ) {
		$users[$u["uid"]]["in"] = $u["speed_rate"];
	} else {
		$users[$u["uid"]]["in"] = $speed[$u["gid"]]["in"];
	}
	if ( $u["speed_rate"] != 0 ) {
		$users[$u["uid"]]["out"] = $u["speed_burst"];
	} else {
		$users[$u["uid"]]["out"] = $speed[$u["gid"]]["out"];
	}
}

foreach($users as $user) {
	array_push($text, "{$user["login"]}	Cleartext-Password :='{$user["password"]}',	NAS-Port-Type == Virtual \n");
    array_push($text, "		Framed-IP-Address ={$user["fip"]}, Filter-Id={$user["in"]}/{$user["out"]} \n");
	array_push($text, "\n");
	if( $user["mac"] != "" ) {
//		array_push($text, "{$user["mac"]}	Cleartext-Password :={$user["mac"]},	NAS-Port-Type == Ethernet \n");
$mac_lower = mb_strtolower($user["mac"], 'UTF-8');
array_push($text, "$mac_lower	Cleartext-Password :=$mac_lower,	NAS-Port-Type == Ethernet \n");
		array_push($text, "		Framed-IP-Address ={$user["ip"]}, DHCP-Mask = {$user["mask"]}, DHCP-Router-IP-Address = {$user["gateway"]}, Filter-Id={$user["in"]}/{$user["out"]} \n");
		array_push($text, "\n");
	}
}

if(file_exists($file_name)) {
	file_put_contents($file_name, "");
}
	
foreach($text as $line) {
	file_put_contents($file_name, $line, FILE_APPEND);
}
