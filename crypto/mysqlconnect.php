<?php

Class Database{

  private $link;

  public function __construct()
  {
  
  }

  private function connect()
  {
    this->link=new PDO($dsn, $username, $password);
  }
  
  public function execute($sql)
  {
  
  }
  
  public function query($sql)
  {
  
  }
}
