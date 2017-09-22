<?php
require_once( "mysqlconnect.php" );
$config=require_once 'radcash_conf.php';
$mysqlconnect=new mysqlconnect();
$file_uids="uids.tmp";
$max_uid_file="max_uid.tmp";

function save($str){
global $file;
global $config;
file_put_contents ($config['upload_file'],$str."\n", FILE_APPEND);
}

if(file_exists($file_uids)){
file_put_contents ($file_uids,"");
}

$max_uid=$mysqlconnect->query("SELECT MAX( uid ) FROM users");
$max_uid=$max_uid[0]["MAX( uid )"];
//print_r($max_uid);

$max_uid_old=file_get_contents($max_uid_file);
//print_r($max_uid_old);
if($max_uid>$max_uid_old){
	file_put_contents ($config['upload_file'],"");
	save("/tool user-manager user");

if($config['use_mac_onu']!=0){
    $users=$mysqlconnect->query("SELECT u.uid, u.local_ip, local_mac, u.gid, u.sectorid, u.speed_rate, u.speed_burst, r.username FROM radacct r, users u, packets t WHERE u.uid>$max_uid_old AND r.radacctid = ( SELECT MAX( r.radacctid ) FROM radacct r WHERE r.uid = u.uid ) AND r.username LIKE \"%:%\" AND u.deposit + u.credit >=0 - t.razresh_minus AND u.blocked =0 AND u.gid = t.gid");
    $mac_type="username";
} else {
    $users=$mysqlconnect->query("SELECT u.uid, u.local_ip, u.local_mac, u.gid, u.sectorid, u.speed_rate, u.speed_burst FROM users u, packets t WHERE u.uid>$max_uid_old AND u.local_mac!='' AND u.deposit + u.credit >=0 - t.razresh_minus AND u.blocked =0 AND u.gid = t.gid");
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
            file_put_contents($file_uids,$uid."\n",FILE_APPEND);
	    }
    }
}
	

file_put_contents($max_uid_file,$max_uid);


function upload(){
global $config;
// $1-UPLOAD_FILE $2-CONNECT_INTERVAL $3-CONNECT_SUM $4-USERMAN_IP $5-$USERMAN_SSH_PORT $6-$USERMAN_LOGIN $7-$USERMAN_APPLY.
$dir=dirname(__FILE__);
$upload_file=$dir."/".$config['upload_file'];
$file=$dir."/radcash_upload.sh";
$file.=" ".$upload_file." ".$config['connect_inteval']." ".$config['connect_sum'];
$file.=" ".$config['userman_ip']." ".$config['userman_ssh_port']." ".$config['userman_login']." ".$config['userman_apply'];
system("bash $file");
}
//upload();


?>
