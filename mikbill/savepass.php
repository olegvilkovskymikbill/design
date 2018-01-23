<?php
require_once( "mysqlconnect.php" );
$mysqlconnect=new mysqlconnect();

$line_username="rlm_perl: Added pair User-Name";
$line_pass="rlm_perl: Added pair User-Password";

$load="/home/sergeev/rad/log";
$last=0;

function start($min){
global $mysqlconnect;
global $line_username;
global $line_pass;
global $load;
global $last;

$lines = file($load);

$max=count($lines)-1;
for($i=$last;$i<$max;$i++){
$res = substr($lines[$i], 0, 30);
    if($res==$line_username){
        $user=substr($lines[$i], 33,-1);

        $res_2=substr($lines[$i+1], 0, 34);
        if($res_2==$line_pass){

        $pass=substr($lines[$i+1], 37, -1);

        $sql=$mysqlconnect->load("SELECT uid, password FROM `users` WHERE `user`='$user'");
        if(count($sql)!=0){
            $load_uid=$sql[0]["uid"];
            $load_pass=$sql[0]["password"];
            echo "uid=$load_uid login=$user     ";
            if($load_pass=="1"){
                echo "меняем пароль: $pass\n";
                $mysqlconnect->save("UPDATE `users` SET `password`='$pass' WHERE `uid`='$load_uid'");
            } else {
                echo "пароль уже изменен: $load_pass\n";
            }
        }
        }

    }
}
$last=$i;

}

while(true){
    start($last);
}

?>
