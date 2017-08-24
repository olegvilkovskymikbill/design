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
  
  }
  
  public function query($sql)
  {
  
  }
}
