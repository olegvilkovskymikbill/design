<?php

Class Database{

  private $link;

  public function __construct()
  {
    $this=>connect();
  }

  private function connect()
  {
    $config=require_once 'config.php';
    
    $dsn='mysql:host='.$config['host'].';dbname='.$config['db_name'].';charset='.$config['charset'];
    
    this->link=new PDO($dsn, $username, $password);
    
    return $this;
  }
  
  public function execute($sql)
  {
    $sth=$this->link->prepare($sql);
    
    return $sth->execute();
  }
  
  public function query($sql)
  {
    $sth=$this->link->prepare->($sql);
    
    $sth->execute();
    
    $result=$sth->fetchAll(PDO::FETCH_ASSOC);
    
    if($result===false){
      return []; 
    }
    
    return $result;
  }
}

$db=new Database();

$db->execute("INSERT INTO 'user' SET 'username'='Artem'");
