<?php

Class mysqlconnect{

  private $link;

  public function __construct()
  {
    $this->connect();
  }

  private function connect()
  {
  global $config;
//    $config=require_once '/var/www/mikbill/login/zmayo/config.php';
//    print_r($config);
    
    $dsn='mysql:host='.$config['host'].';dbname='.$config['db_name'].';charset='.$config['charset'];
    //echo $config['username'];
    
    $this->link=new PDO($dsn, $config['username'], $config['password']);
    
    return $this;
  }
  
  public function save($sql)
  {
    $sth=$this->link->prepare($sql);
    
    return $sth->execute();
  }
  
  public function load($sql)
  {
    $sth = $this->link->prepare($sql);
    
    $sth->execute();
    
    $result=$sth->fetchAll(PDO::FETCH_ASSOC);
    
//    if($result === false){
//      return [];
//    }
    
    return $result;
  }
}

