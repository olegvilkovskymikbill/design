<?php
Class radcash_lib{
function upload($config){
// $1-UPLOAD_FILE $2-CONNECT_INTERVAL $3-CONNECT_SUM $4-USERMAN_IP $5-$USERMAN_SSH_PORT $6-$USERMAN_LOGIN $7-$USERMAN_APPLY
$dir=dirname(__FILE__);
$upload_file=$dir."/".$config['upload_file'];
$file=$dir."/radcash_upload.sh";
$file.=" ".$upload_file." ".$config['connect_inteval']." ".$config['connect_sum'];
// Дальше добавлять микротики
$file_1=$file." ".$config['userman_ip']." ".$config['userman_ssh_port']." ".$config['userman_login']." ".$config['userman_apply'];
system("bash $file_1");
}
//upload();
}
?>
