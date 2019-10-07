# guildin_infra
guildin Infra repository

#Исследовать способ подключения к someinternalhost в одну
#команду из вашего рабочего устройства, проверить
#работоспособность найденного решения и внести его в
#README.md в вашем репозитории
ssh -i ~/.ssh/gcp_id.rsa -A -J atikhonov.gcp@34.76.12.102 atikhonov.gcp@10.132.0.3

#Дополнительное задание:
#Предложить вариант решения для подключения из консоли при
#помощи команды вида ssh someinternalhost из локальной
#консоли рабочего устройства, чтобы подключение выполнялось по
#алиасу someinternalhost и внести его в README.md в вашем
#репозитории
xxx$ cat ~/.ssh/config 
Host bastion
	HostName 34.76.108.95
	User atikhonov.gcp
	IdentityFile ~/.ssh/gcp_id_rsa
Host someinternalhost
	HostName 10.132.0.3
	User atikhonov.gcp
	ProxyJump bastion

bastion_IP = 34.76.108.95
someinternalhost_IP = 10.132.0.3

##Деплой тестового приложения

###Проверка ДЗ
##Установка GC SDK:
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
#Prerequisites
apt-get install apt-transport-https ca-certificates
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk

#создание нового экземпляра приложения:
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --metadata-from-file startup-script=install_n_deploy.sh \
  --restart-on-failure

-логин в ВМ reddit-app
-установка ruby (sudo apt update && sudo apt install -y ruby-full ruby-bundler build-essential)
-Проверка ruby (ruby -v) >>> ruby 2.3.1p112 (2016-04-26) [x86_64-linux-gnu]
-Проверка bundler (bundler -v) >>> Bundler version 1.11.2

#Установка MongoDB
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update
sudo apt install -y mongodb-org
#troubleshooting:
GPG error: http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 Release: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY D68FA50FEA312927
-sudo rm /etc/apt/sources.list.d/mongodb*.list
-sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E52529D4
-sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.2.list'
-sudo apt update
-sudo apt install -y mongodb-org

#Запуск MongoDB, установка службы, проверка
-sudo systemctl start mongod
-sudo systemctl enable mongod
-sudo systemctl status mongod

#Deploy
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install 

#Настройка брандмауэра:
-создано правило default-puma-server с тегом puma-server для 0.0.0.0/0 на порт 9292 
-проверена работоспособность веб-интерфейса

#самостоятельная работа
-скрипты install_ruby.sh, install_mongodb.sh, deploy.sh созданы, сделаны исполняемыми
-на их базе сформирован startup_script install_n_deploy.sh:
-проверена его работа на автодеплое экземпляра:
gcloud compute instances create reddit-app4\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --metadata-from-file startup-script=install_n_deploy.sh \
  --restart-on-failure

#Дополнительное задание
 default-puma-server - удалить и создать заново
-смотрим что есть:
gcloud compute firewall-rules list
-удаляем default-puma-server
gcloud compute firewall-rules delete default-puma-server
-проверяем коннект - нет, создаем новое правило:
gcloud compute firewall-rules create default-puma-server --allow tcp:9292 --source-tags=puma-server --source-ranges=0.0.0.0/0
-Ждем некоторое время... Profit!


testapp_IP = 104.155.111.133 
testapp_port = 9292 


#Сборка образов VM при помощи Packer

##Базовое задание
- Установлен packer (packer.io), создан ADC для авторизации:
gcloud auth application-default login
- созданы шаблон и файл уточнений для него: ubuntu16.json и variables.json[.example]; с помощью packer validate проверена корректность синтаксиса
Данные файлы описывают образ ВМ ubuntu-1604-lts с установленными ruby и mongodb
- используя вышеуказанные файлы сформирован образ reddit-base-[дата] семейства reddit-base (наименования условные) 

##Самостоятельное задание
- Файл с переменными variables.json, внесен в .gitignore
- Пользовательские данные выведены в variables.json
- variables.json.example

##Задание со *
- На основе шаблона reddit-base создан шаблон immutable.json (семейство reddit-full). Данный шаблон описывает развертывание на базовом шаблоне puma server.
- puma.service описывает запуск сервиса через systemd.unit
- Сценарий create-redditvm.sh написан. 

