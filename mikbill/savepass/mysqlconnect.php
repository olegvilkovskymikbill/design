<?php
Class mysqlconnect{
  private $link;
  public function __construct()
  {
    $this->connect();
  }
  private function connect()
  {
    $dsn='mysql:host='."localhost".';dbname='."mikbill".';charset='."koi8r";
    //echo $config['username'];
    $this->link=new PDO($dsn, "mikbill", "QcN8qsUuRX4X");
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
    return $result;
  }
}
