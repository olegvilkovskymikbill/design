<?php
require_once( "mysqlconnect.php" );
$config=require_once 'radcash_conf.php';
$mysqlconnect=new mysqlconnect();
global $config;
$file_trigger="trigger.tmp";
$max_uid_file="max_uid.tmp";
$file_uids="uids.tmp";

    $uid_max=$mysqlconnect->query("SELECT MAX( uid ) FROM users");
    $uid_max=$uid_max[0]["MAX( uid )"];
    file_put_contents($max_uid_file,$uid_max);

function save($str){
global $config;
file_put_contents ($config['upload_file'],$str."\n", FILE_APPEND);
}
// Тарифы
$gids=$mysqlconnect->query("SELECT gid, speed_burst, speed_rate FROM packets");
file_put_contents ($config['upload_file'],"/tool user-manager profile\n");
save("limitation remove [find]");
save("remove numbers=[find]");
    for($i=0;$i!=count($gids);$i++){
    save("limitation add name=".$gids[$i]["gid"]." owner=admin rate-limit-rx=".$gids[$i]["speed_burst"]."k rate-limit-tx=".$gids[$i]["speed_rate"]."k");
    save("add name=".$gids[$i]["gid"]." owner=admin");
    save("profile-limitation add profile=".$gids[$i]["gid"]." limitation=".$gids[$i]["gid"]."\n");
    }
if($config['userman_log_remove']!=0)save("/tool user-manager log remove numbers=[find]");
save("/tool user-manager user remove [find]");

// Абоненты
file_put_contents($file_uids,"");
//file_put_contents($config["mac_tmp"],"");
$authorization="hotspot";
save("/tool user-manager user");

if($config['radius_hotspot']!=0){
file_put_contents ($config['mac_tmp'],'');

if($config['use_mac_onu']!=0){
    $users=$mysqlconnect->query("SELECT u.uid, u.local_ip, local_mac, u.gid, u.sectorid, u.speed_rate, u.speed_burst, r.username FROM radacct r, users u, packets t WHERE r.radacctid = ( SELECT MAX( r.radacctid ) FROM radacct r WHERE r.uid = u.uid ) AND r.username LIKE \"%:%\" AND u.deposit + u.credit >=0 - t.razresh_minus AND u.blocked =0 AND u.gid = t.gid");
    $mac_type="username";
} else {
    $users=$mysqlconnect->query("SELECT u.uid, u.local_ip, u.local_mac, u.gid, u.sectorid, u.speed_rate, u.speed_burst FROM users u, packets t WHERE u.local_mac!='' AND u.deposit + u.credit >=0 - t.razresh_minus AND u.blocked =0 AND u.gid = t.gid");
    $mac_type="local_mac";
}
print_r($users);
    for($i=0;$i!=count($users);$i++){
	 $mac=$users[$i][$mac_type];
	if($mac_type=="username"){
	    if($mac==NULL)$mac=$users[$i]["local_mac"];
	}
	if(strpos(file_get_contents($config["mac_tmp"]), $mac)){
	    echo "МАК уже есть: $mac\n";
	} else {
	    $uid=$users[$i]["uid"];
	    file_put_contents ($config["mac_tmp"],$mac."\n",FILE_APPEND);
	    $ip=$users[$i]["local_ip"];
	    $gid=$users[$i]["gid"];
	    $speed_rate=$users[$i]["speed_rate"];
	    $speed_burst=$users[$i]["speed_burst"];
		if($speed_rate !=0 or $speed_burst !=0){
		    $gid=$authorization.$uid;
		    save("/tool user-manager profile limitation add name=$gid owner=admin rate-limit-rx=$speed_rate"."k"." rate-limit-tx=$speed_burst"."k");
		    save("/tool user-manager profile add name=$gid owner=admin");
		    save("/tool user-manager profile profile-limitation add profile=$gid limitation=$gid");
		}
	    
	    save("add customer=admin username=$mac ip-address=$ip");
	    save("create-and-activate-profile profile=$gid \"$mac\" customer=admin");
	    save("\n");
		
		}
	file_put_contents($file_uids,$uid."\n",FILE_APPEND);
	}
}

if($config['radius_ppp']!=0){
//$users=$mysqlconnect->query("SELECT u.user, u.gid, u.framed_ip, u.speed_rate, u.speed_burst FROM users

}
// Upload
require_once( "radcash_lib.php" );
$radcash_lib=new radcash_lib();
$radcash_lib->upload($config);

file_put_contents($file_trigger,"");
?>
