<?php
return array(
// Mysql
  'host' => 'localhost',
  'db_name' => 'mikbill',
  'username' => 'mikbill',
  'password' => '1394xl',
  'charset' => 'utf8',
// Mikrotik  
  'userman_ip' => '192.168.10.67',	// IP микротика
  'userman_ssh_port' => '22',		// Порт микротика
  'userman_login' => 'mikbill',		// Логин учетки микротика (не забываем настроить авторизацию по ключу)
  'userman_apply' => '1',		// При значении 0 скрипт заливается, но не выполняется
// Global
  'userman_log_remove' => '1',		// Удаляет предыдущий лог User Manager при общей заливке
  'radius_hotspot' => '1',		// Вкл/выкл IPOE NAS
  'radius_ppp' => '1',			// Вкл/выкл PPP NAS
  'use_mac_onu' => '1', 		// Вкл/выкл авторизацию по MAC-ONU 
// Files
  'upload_file' => 'upload.rsc',
  'mac_tmp' => 'mac.tmp',
  'max_uid_file' => 'max_uid.tmp',
// Upload settings
  'connect_inteval' => '60',
  'connect_sum' => '180'
);
