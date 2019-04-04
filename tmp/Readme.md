2.1 Configure Container
Ansible задачу писал по рекомендациям с best practices
В configure_container.yml запуск двух ролей: 
  docker_install - установка Docker, сделана для полной настройки чистого сервера, 
    когда настройка проходит на удаленном сервере.
  configure_container - сборка образа Docker из Dockerfile, запуск контейнера с с установленными Jdk 8 и JBoss 6.4 
