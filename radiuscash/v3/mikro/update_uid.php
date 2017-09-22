<?php
if(file_exists("trigger.tmp")){
require_once( "mysqlconnect.php" );
$config=require_once 'radcash_conf.php';
$mysqlconnect=new mysqlconnect();
$file_uids="uids.tmp";

function save($str){
global $file;
global $config;
file_put_contents ($config['upload_file'],$str."\n", FILE_APPEND);
}

if(file_exists($file_uids))file_put_contents ($file_uids,"");
if(file_exists($config["mac_tmp"]))file_put_contents ($config["mac_tmp"],"");

$uid=$argv[1];

	file_put_contents ($config['upload_file'],"");
	save("/tool user-manager user");

if($config['use_mac_onu']!=0){
    $users=$mysqlconnect->query("SELECT u.uid, u.local_ip, local_mac, u.gid, u.sectorid, u.speed_rate, u.speed_burst, r.username FROM radacct r, users u, packets t WHERE u.uid=$uid AND r.radacctid = ( SELECT MAX( r.radacctid ) FROM radacct r WHERE r.uid = u.uid ) AND r.username LIKE \"%:%\" AND u.deposit + u.credit >=0 - t.razresh_minus AND u.blocked =0 AND u.gid = t.gid");
    $mac_type="username";
} else {
    $users=$mysqlconnect->query("SELECT u.uid, u.local_ip, u.local_mac, u.gid, u.sectorid, u.speed_rate, u.speed_burst FROM users u, packets t WHERE u.uid=$uid AND u.local_mac!='' AND u.deposit + u.credit >=0 - t.razresh_minus AND u.blocked =0 AND u.gid = t.gid");
    $mac_type="local_mac";
}
//print_r($users);
if (empty($users)==false){
    $mac=$users[0][$mac_type];
        if($mac_type=="username"){
            if($mac==NULL)$mac=$users[0]["local_mac"];
        }
    
        if(strpos(file_get_contents($config["mac_tmp"]), $mac)){
            echo "МАК уже есть: $mac\n";
        } else {
            $uid=$users[0]["uid"];
            file_put_contents ($config["mac_tmp"],$mac."\n",FILE_APPEND);
            $ip=$users[0]["local_ip"];
            $gid=$users[0]["gid"];
            $speed_rate=$users[0]["speed_rate"];
            $speed_burst=$users[0]["speed_burst"];
            	    if($speed_rate !=0 or $speed_burst !=0){
                    $gid=$authorization.$uid;
                    save("/tool user-manager profile limitation add name=$gid owner=admin rate-limit-rx=$speed_rate"."k"." rate-limit-tx=$speed_burst"."k");
                    save("/tool user-manager profile add name=$gid owner=admin");
                    save("/tool user-manager profile profile-limitation add profile=$gid limitation=$gid");
            	    }                
            save("add customer=admin username=$mac ip-address=$ip");
            save("create-and-activate-profile profile=$gid \"$mac\" customer=admin");
            save("\n");
            file_put_contents($file_uids,$uid."\n",FILE_APPEND);
	}
	
// Upload
//echo $config['upload_file'];
require_once( "radcash_lib.php" );
$radcash_lib=new radcash_lib();
$radcash_lib->upload($config);
    }

}
?>
