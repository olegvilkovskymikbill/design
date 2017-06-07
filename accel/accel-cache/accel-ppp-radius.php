<?php
	define ("BILL_AUTH_TABLE","users");
	define ("BILL_NAS_TABLE", "radnas" );
	define ("BILL_NASLOG_TABLE", "radnaslog" );
	define ("BILL_SYSPOTS_TABLE", "sysopts" );
	define ("BILL_PACKET_TABLE", "packets" );	
	$config_file='../../app/etc/config.xml';
	$DHCP_Router_IP_address="172.16.0.1";
	$gen_framed=false;


	$scp_command="/usr/bin/scp";
	$rad_user_file="/var/www/mikbill/admin/res/cache/users"; 
#	$rad_nas_path="/etc/freeradius";
$rad_nas_path="/opt/accel-cache/users";
	$rad_nas_restart="/etc/init.d/freeradius restart";


	if (file_exists($config_file)) {
		$xml = simplexml_load_file($config_file);
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

	function init_sysopts($LINK,$stdlog)
        {
                $result = mysql_query ( "SELECT * FROM " . BILL_SYSPOTS_TABLE . " WHERE 1 ", $LINK ) or do_log_sql($stdlog,"#6 ".mysql_error ( $LINK ),$LINK );
                $res = mysql_fetch_array ( $result );
                mysql_free_result ( $result );

                return $res;
        }



	function get_date()
	{
		return date ( 'd.m.Y H:i:s' );
	}

	function billing_init_users($LINK,$stdlog)
	{
	    $packets = array();

#	    $query =  "SELECT users.uid, users.gid, packets.gid, packets.speed_rate, users.user, ";
#	    $query .= "users.password, users.framed_ip, users.framed_mask, users.local_mac, users.local_ip, users.real_ip "; 
#	    $query .= "FROM `users` left join packets on users.gid=packets.gid where users.deposit+users.credit>=0";

	    $query =  "SELECT users.uid, users.gid, packets.gid, packets.speed_rate, users.user, sectors.mask,sectors.routers,";
	    $query .= "users.password, users.framed_ip, users.framed_mask, users.local_mac, users.local_ip, users.real_ip "; 
	    $query .= "FROM `users` ";
	    $query .= "left join packets on users.gid=packets.gid ";
	    $query .= "join sectors on users.sectorid=sectors.sectorid ";
	    $query .= "where users.deposit+users.credit>=0";


	    $result = mysql_query ($query, $LINK ) or do_log_sql($stdlog,"#1 ".mysql_error($LINK),$child ); 

	    for ($i = 0; $i < mysql_num_rows($result); $i++) {
		$res = mysql_fetch_array($result);
		$packets[$res["uid"]]=$res;
	    }
	    mysql_free_result($result);
	    return $packets;
	}

	function get_ip_gateway($LINK, $stdlog)
	{

	    $query = "SELECT * FROM system_options where `key` like 'accel_ipoe_real_gw'";

	    $result = mysql_query ($query, $LINK ) or do_log_sql($stdlog,"#1 ".mysql_error($LINK),$child );

	    $row = mysql_fetch_array($result);

	    $ip_gateway=$row["value"];

	    return $ip_gateway;

	}

	function get_nas($LINK,$stdlog)
        {

		$query = "SELECT * FROM ".BILL_NAS_TABLE." WHERE usessh=1 and shapertype=4 and nastype LIKE 'accel%'";
		$result = mysql_query ($query, $LINK ) or do_log_sql($stdlog,"#1 ".mysql_error($LINK),$child ); 

                for ($i = 0; $i < mysql_num_rows ($result); $i++) {
                        $res = mysql_fetch_array ( $result );
                        $nases[$i]=$res;
                }

                mysql_free_result ( $result );

                return $nases;
        }


function mask2cidr($mask){
    $long = ip2long($mask);
    $base = ip2long('255.255.255.255');
    return 32-log(($long ^ $base)+1,2);

}
			
	global $LINK;

	$LINK = mysql_pconnect ( $CONF_MYSQL_HOST ,  $CONF_MYSQL_USERNAME, $CONF_MYSQL_PASSWORD );
	if (!$LINK) {
		do_log($stdlog,"Cant connect to DB ".$CONF_MYSQL_HOST);
		exit();
	}

	mysql_select_db ( $CONF_MYSQL_DBNAME , $LINK ) or die('Could not select database.');


	$router_ip_real=get_ip_gateway($LINK,$stdlog);
	if($router_ip_real=="") $router_ip_real=$DHCP_Router_IP_address;

        $users = billing_init_users($LINK,$stdlog);

	$file_name='./users';
	$data_file='';

	foreach ($users as $key=>$value)
	{
		if ($value['local_mac']<>""){
			$local_mac = mb_strtolower($value['local_mac']);

			if ($gen_framed){
				if ($value['framed_ip']<>"") {
					$framed_ip=$value['framed_ip'];
				
					if ($value['framed_mask']<>"") $framed_mask = mask2cidr($value['framed_mask']); else $framed_mask="32";
			        
					if ($value['real_ip']==1)$router_ip = $router_ip_real; else $router_ip = $DHCP_Router_IP_address;
				}
			}
			 else {
					if ($value['local_ip']<>"") {
						$framed_ip=$value['local_ip'];
						if ($value['mask']<>"") $framed_mask = mask2cidr($value['mask']); else $framed_mask="32";
						if ($value['routers']<>"") $router_ip = $value['routers']; else $router_ip=$DHCP_Router_IP_address;
						if ($value['real_ip']==1){ 
							$framed_ip=$value['framed_ip'];
							$framed_mask="255.255.255.255";
							$router_ip = $router_ip_real; 
						}
					}
				}

			$speed_rate = $value['speed_rate'];

			$data_file .= $local_mac."		 Cleartext-Password := \"".$local_mac."\"";
			$data_file .= "\n";
			$data_file .= "		Service-Type = Framed-User, ";
			$data_file .= "Framed-IP-Address = ".$framed_ip.", ";
#			$data_file .= "Framed-IP-Netmask = ".$framed_mask.", ";
			$data_file .= "DHCP-Mask = ".$framed_mask.", ";
			$data_file .= "DHCP-Router-IP-Address = ".$router_ip.", ";
			$data_file .= "Filter-Id = ".$speed_rate."/".$speed_rate;
			$data_file .= "\n\n";
		}//enf if local_mac
	}
	file_put_contents($file_name,$data_file);


        $sysoptions = init_sysopts($LINK,$stdlog);
#        $ssh=$sysoptions['ssh_path'];
$ssh="/usr/bin/ssh";

	$nas=get_nas($LINK,$stdlog);
#$nas=123;
#echo $nas[0];

#	var_dump($nas);	

	foreach ($nas as $key=>$value){
	    if (isset($value['nasname'])) {
echo $value['naslogin'];
#echo 123;
		$command=$scp_command." ".'-P'." ".'2280'." ".$rad_user_file." ".$value['naslogin'].'@'.$value['nasname'].":".$rad_nas_path;
#	exec($command." &>/dev/null 2>&1");
exec($command);


		$command=$ssh." ".$value['naslogin'].'@'.$value['nasname']." '".$rad_nas_restart."'";
		exec($command." &>/dev/null 2>&1");
	    }
	}







