<?php
$config=require_once 'config.php';
require_once( "mysqlconnect.php" );
$mysqlconnect=new mysqlconnect();

$passport_date="1980-12-05";

$uids=$mysqlconnect->load("SELECT uid FROM `users`");
//print_r($uids);
$users_custom_fields=$mysqlconnect->load("SELECT uid FROM `users_custom_fields` WHERE `key` = 'ext_passport_date'");
//print_r($users_custom_fields);
$count_uids=count($uids);
$count_users_custom_fields=count($users_custom_fields);
for($i=0;$i<$count_uids;$i++){
    for($n=0;$n<$count_users_custom_fields;$n++){
	if($uids[$i]["uid"]==$users_custom_fields[$n]["uid"]){
	    
	    break;
	}
//	if($n=="$count_users_custom_fields"){
//	    echo $uids[$i]["uid"];
//	}
    }
    if($n=="$count_users_custom_fields"){
        $uid=$uids[$i]["uid"];
	$mysqlconnect->save("INSERT INTO `users_custom_fields`(`uid`, `key`, `value`) VALUES ('$uid','ext_passport_date', '$passport_date')");
    }
    
}

?>
