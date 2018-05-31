<?php
#header("Content-type: text/plain");

$is_console = PHP_SAPI == 'cli' || (!isset($_SERVER['DOCUMENT_ROOT']) && !isset($_SERVER['REQUEST_URI']));
if( $is_console ) {
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
    
    
    $QUERY_GET_LEGAL="SELECT uid FROM users_custom_fields WHERE `key`='ext_legal_person' and `value`='1'";
    $sql = $db->prepare($QUERY_GET_LEGAL); $sql->execute();
    $legal = $sql->fetchAll(PDO::FETCH_ASSOC);
    
    $QUERY_GET_USERS="SELECT uid, user FROM users WHERE user REGEXP BINARY '-[0-9]+$'";
    $sql = $db->prepare($QUERY_GET_USERS); $sql->execute();
    $res = $sql->fetchAll(PDO::FETCH_ASSOC);
    if ($sql->rowCount() > 0) {
        foreach ($res as $value) {

    $result = array_filter($legal, function($innerArray){
    global $value;
    return in_array($value["uid"], $innerArray);
    });

        if ($result!=NULL) {
        print_r ($value["uid"]);
            $name = null;
            $name_tmp=explode("-", $value["user"]);
            $len = count($name_tmp);

            if( $len == 2 ) {
                if( is_numeric($name_tmp[1]) ) {
                    $name = $name_tmp[0];
                }
            } else {
                if( $len > 2 ) {
                    foreach( $name_tmp as $t ) {
                        if ($t === end($name_tmp)) {
                            break;
                        }

                        if( $t === reset($name_tmp) ) {
                            $name .= $t;
                        } else {
                            $name .= "-" . $t;
                        }
                    }
                } else {
                    # len = 1 ?
                }
            }
            

            $QUERY_GET_USER="SELECT uid, deposit, credit, blocked FROM users WHERE user = '{$name}'";
            echo "{$QUERY_GET_USER}\n";
            $sql = $db->prepare($QUERY_GET_USER); $sql->execute();
            $req = $sql->fetchAll(PDO::FETCH_ASSOC);
            if ($sql->rowCount() > 0) {
                foreach ($req as $eq) {
            	    echo $eq["uid"];
                    $users_list[$name]["uid"] = $eq["uid"];
                    $users_list[$name]["deposit"] = $eq["deposit"];
                    $users_list[$name]["credit"] = $eq["credit"];
                    $users_list[$name]["blocked"] = $eq["blocked"];
                }
            }
        }
        }

        foreach ($users_list as $user=>$value) {
            if(isset($value["uid"])) {
            //echo $u;
                    //echo "update user: {$user}, uid: {$value["uid"]}";
                    # deposit
                    $QUERY_UPDATE = "UPDATE users SET deposit={$value["deposit"]} WHERE user REGEXP BINARY '{$user}-[0-9]+$'";
                    # deposit + blocked
                    //$QUERY_UPDATE = "UPDATE users SET deposit={$value["deposit"]}, blocked={$value["blocked"]} WHERE user REGEXP BINARY '{$user}-[0-9]+$'";
                    # deposit + credit + blocked
                    //$QUERY_UPDATE = "UPDATE users SET deposit={$value["deposit"]}, credit={$value["credit"]}, blocked={$value["blocked"]} WHERE user REGEXP BINARY '{$user}-[0-9]+$'";
                    $db->exec($QUERY_UPDATE);
            } else {
                //echo "main user not found \n";
            }
        }
    } else {
        //echo "No users found \n";
    }
} else {
    echo "Script must be running from console!";
}
