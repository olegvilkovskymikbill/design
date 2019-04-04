2.1 Configure Container

Ansible задачу писал по рекомендациям с best practices

Первая задача выполнена с возможностьтью установки на удаленный сервер, остальные, так как такого в задачах не указано и требует больше времени, выполнены на сервере Jenkins.

В configure_container.yml запуск двух ролей: 

docker_install - установка Docker, сделана для полной настройки чистого сервера, 
    когда настройка проходит на удаленном сервере.

  Описание переменных:
      docker_install_distribution - репозиторий для закачки пакета Docker.

configure_container - сборка образа Docker из Dockerfile, запуск контейнера с с установленными Jdk 8 и JBoss 6.4.
    Контейнер ставится на OS Centos7 и уничтожается через 15 минут работы.
    Удаление организованно запуском скрипта ENTRYPOINT с sleep 900, а контейнер запущен с параметром --rm

  Описание переменных:
      configure_container_containername - название создаваемого Docker-контейнера
      configure_container_imagename - название создаваемого Docker-образа
      configure_container_port8080 - порт, на котором будет перенаправление на внутренний порт контейнера 8080
      configure_container_port9990 - порт, на котором будет перенаправление на внутренний порт контейнера 9990
      configure_container_port9999 - порт, на котором будет перенаправление на внутренний порт контейнера 9999
      
Работа скрипта протестирована на локальной и удаленной машине (Ubuntu 18.04.2 LTS)

Для запуска в Jenkins использовал плагин ansible. 
Также файлы configure_container.yml и hosts сделал редактируемыми из Jenkins.  


2.2 Build Application

Код в Jenkins:
  rm -rf UT
  git clone https://github.com/kadrist/UT.git
  cd UT
  git checkout -b myBranch1
  mvn clean install
  cp target/devops-test.war /tmp/

Удаляю каталог, загружаю репозиторий, создаю локальную ветку, собираю devops-test.war и переношу в временный каталог


2.3 Deploy Application
Код в Jenkins:
  sudo cp /tmp/devops-test.war /usr/local/share/jboss/standalone/deployments
  cd /usr/local/share/jboss/bin
  ./standalone.sh -Djboss.bind.address=192.168.10.101 -Djboss.bind.address.management=192.168.10.101&
  
Копирую файл war в каталог для deploy и запускаю deploy
Результат в приложенном скрине.


2.4 Manage Deployment

Для этой задачи использовал плагины:	
  Extended Choice Parameter - выбор checkbox
  Parameterized Trigger plugin - запуск другой задачи 



