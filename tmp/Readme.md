2.1 Configure Container
Ansible задачу писал по рекомендациям с best practices
В configure_container.yml запуск двух ролей: 
  docker_install - установка Docker, сделана для полной настройки чистого сервера, 
    когда настройка проходит на удаленном сервере.
    Описание переменных:
      docker_install_distribution - репозиторий для закачки Docker
  configure_container - сборка образа Docker из Dockerfile, запуск контейнера с с установленными Jdk 8 и JBoss 6.4 
    Описание переменных:
      configure_container_containername - название создаваемого Docker-контейнера
      configure_container_imagename - название создаваемого Docker-образа
      configure_container_port8080 - порт, на котором будет перенаправление на внутренний порт контейнера 8080
      configure_container_port9990 - порт, на котором будет перенаправление на внутренний порт контейнера 9990
      configure_container_port9999 - порт, на котором будет перенаправление на внутренний порт контейнера 9999

