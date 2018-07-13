<?php

$SMS_UKR_LOGIN="380986860136";
$SMS_UKR_PASS="cvcsltz132";
$COMPANY="Idea_Inet";
$TEXT_base="Shanovnyy abonente. Vash balans = ";
$TEXT_infoBody=" Nagadyemo pro neobhidnist popovnyty internet rahynok (min. suma = ";
$TEXT_infoEnd=" grn.)";

$API_URL="http://smsukraine.com.ua/api/xml.php";

define ("BILL_AUTH_TABLE","users");
define ("BILL_NAS_TABLE", "radnas" );
define ("BILL_NASLOG_TABLE", "radnaslog" );
define ("BILL_SYSPOTS_TABLE", "sysopts" );

$config_file='../../app/etc/config.xml';

if (file_exists($config_file)) {
	$xml = simplexml_load_file($config_file);

	$CONF_IP   = (string) $xml->parameters->kernel->ip;
	$CONF_PORT = (string) $xml->parameters->kernel->port;
	$CONF_PID  = (string) $xml->parameters->kernel->pid;
	$CONF_LOG  = (string) $xml->parameters->kernel->log;
	$CONF_MYSQL_HOST     = (string) $xml->parameters->mysql->host;
	$CONF_MYSQL_USERNAME = (string) $xml->parameters->mysql->username;
	$CONF_MYSQL_PASSWORD = (string) $xml->parameters->mysql->password;
	$CONF_MYSQL_DBNAME   = (string) $xml->parameters->mysql->dbname;

} else {
	die("config not found");
}

function open_logs($CONF_LOG)
{
	return 	fopen($CONF_LOG, "a");
}

$stdlog = open_logs($CONF_LOG);


function do_log($stdlog,$text_log)
{
	fputs($stdlog, get_date()." ".$text_log."\n");
}

function do_log_sql($stdlog,$text_log,&$LINK)
{
	if (!mysql_ping($GLOBALS["LINK"]))
	{
		$do_mysql_reconect=1;
		fputs($stdlog, get_date()." MySQL Connect failed"."\n");
	}else{
		$do_mysql_reconect=0;
		fputs($stdlog, get_date()." ".$text_log."\n");
	}

	while ($do_mysql_reconect==1)
	{
		$config_file='../../app/etc/config.xml';

		if (file_exists($config_file)) {
			$xml = simplexml_load_file($config_file);
			$CONF_MYSQL_HOST     = (string) $xml->parameters->mysql->host;
			$CONF_MYSQL_USERNAME = (string) $xml->parameters->mysql->username;
			$CONF_MYSQL_PASSWORD = (string) $xml->parameters->mysql->password;
			$CONF_MYSQL_DBNAME   = (string) $xml->parameters->mysql->dbname;
		}
		$GLOBALS["LINK"] = mysql_pconnect ( $CONF_MYSQL_HOST ,  $CONF_MYSQL_USERNAME, $CONF_MYSQL_PASSWORD );
		mysql_select_db ( $CONF_MYSQL_DBNAME , $GLOBALS["LINK"] );

		if (mysql_ping($GLOBALS["LINK"])){
			$do_mysql_reconect=0;
			fputs($stdlog, get_date()." MySQL Connect restored"."\n");
		}


	}
	return "1";
}


function get_date()
{
	return date ( 'd.m.Y H:i:s' );
}

function get_users_dolgniki($LINK,$stdlog )
{

#	$SQL_Querry="SELECT uid,user,deposit,sms_tel,mob_tel,phone FROM " . BILL_AUTH_TABLE . " WHERE `uid` = 13 ";
	$SQL_Querry="SELECT tu.uid,tu.user,tu.deposit,tu.sms_tel,tu.mob_tel,tu.phone,tu.real_ip,tu.real_price,tu.real_ipfree,tu.gid,tu.fixed_cost AS users_fixed_cost, "
			."tp.packet,tp.fixed,tp.fixed_cost,tp.real_ip AS packet_real_ip,tp.real_price AS packet_real_price "
		    ."FROM ". BILL_AUTH_TABLE ." tu "
		    ."INNER JOIN packets tp ON tu.gid = tp.gid " 
		    ."WHERE tu.uid NOT IN (219) AND tu.deposit > -200 AND tp.fixed = 8 AND NOT (tp.gid IN (8, 21, 29, 31, 32, 33, 38, 39, 40, 41))";

	$result = mysql_query ( $SQL_Querry, $LINK ) or do_log_sql($stdlog,"#deposit error ".mysql_error ( $LINK ) ,$LINK);

	for ($i = 0; $i <= mysql_num_rows ($result); $i++) {
		$res = mysql_fetch_array ( $result );
		$users_list[$i]=$res;
	}
	mysql_free_result ( $result );

	return $users_list;
}

global $LINK;
$LINK = mysql_pconnect ( $CONF_MYSQL_HOST ,  $CONF_MYSQL_USERNAME, $CONF_MYSQL_PASSWORD );
if (!$LINK) {
	do_log($stdlog,"Cant connect to DB ".$CONF_MYSQL_HOST);
	exit();
}

mysql_select_db ( $CONF_MYSQL_DBNAME , $LINK ) or die('Could not select database.');

$users_dolgnki=get_users_dolgniki($LINK,$stdlog);

$querry="<?xml version=\"1.0\" encoding=\"utf-8\" ?>";
$querry.="<package login=\"".$SMS_UKR_LOGIN."\" password=\"".$SMS_UKR_PASS."\">";
$querry.="<message>";

$ts=time();

foreach ($users_dolgnki as $key=>$value)
{
#	var_dump($value);
	$deposit=round($value['deposit'],2);
	
	$packet_real_ip    = $value['packet_real_ip'];
	$packet_real_price = round($value['packet_real_price'],2);
	$real_ip           = $value['real_ip'];
	$real_price        = round($value['real_price'],2);
	$real_ipfree       = $value['real_ipfree'];
	$fixed             = $value['fixed'];
	$fixed_cost        = round($value['fixed_cost'],2);
	$users_fixed_cost  = round($value['users_fixed_cost'],2);
	
	$sum_for_pay = (1-$users_fixed_cost/100) * $fixed_cost - $deposit;
	if (($real_ip == 1) and ($real_ipfree == 0)) {
	    if ($real_price == 0) {
	        if ($packet_real_ip == 1) {
		     $sum_for_pay = $sum_for_pay + $packet_real_price;
		}
	    } else {
		$sum_for_pay = $sum_for_pay + $real_price;
	    }
	}
	if ($sum_for_pay > 0) {
		$TEXT=$TEXT_base.$deposit." grn. ".$TEXT_infoBody.$sum_for_pay.$TEXT_infoEnd;
#		var_dump($TEXT);
#	$TEXT=$TEXT_base.$deposit." grn";
#	$TEXT=iconv("CP1251","KOI8-U",$TEXT);

		$pattern = "|[^\d\(\)-+]|";
		$replacement = "";

		$SMS_TEL=preg_replace($pattern, $replacement, $value['sms_tel']);
	
		if (strlen($SMS_TEL)==12){
			$querry.="<msg id=\"".$ts.$value['uid']."\" recipient=\"".$SMS_TEL."\" sender=\"".$COMPANY."\" type=\"0\">".$TEXT."</msg>";
		}
		if (strlen($SMS_TEL)==10){
			$querry.="<msg id=\"".$ts.$value['uid']."\" recipient=\"38".$SMS_TEL."\" sender=\"".$COMPANY."\" type=\"0\">".$TEXT."</msg>";
		}
		if ((strlen($SMS_TEL)<9)or(strlen($SMS_TEL)>12)){
		}
		if (strlen($SMS_TEL)==11){
			$querry.="<msg id=\"".$ts.$value['uid']."\" recipient=\"3".$SMS_TEL."\" sender=\"".$COMPANY."\" type=\"0\">".$TEXT."</msg>";
		}
	}
}
$querry.="</message>";
$querry.="</package>";



#$querry=iconv("KOI8-U","UTF-8",$querry);
#var_dump(iconv("UTF-8","KOI8-U",$querry));
function do_post_request($url, $data, $optional_headers = null){
    $params = array('http'=>array('method'=>'POST','content'=>$data));
    if($optional_headers !== null){
        $params['http']['header'] = $optional_headers;
    }
    $ctx = stream_context_create($params);
    $fp = @fopen($url, 'rb', false, $ctx);
#    var_dump($url);
#    var_dump($fp);
    if(!$fp){
        throw new Exception("Problem with $url, $php_errormsg"); 
    } 
    $response = @stream_get_contents($fp);
    if($response === false){
        throw new Exception("Problem reading data from $url, $php_errormsg"); 
    } 
#    var_dump($response);
    return $response; 
} 

$return=do_post_request($API_URL,$querry);

#var_dump($return);
