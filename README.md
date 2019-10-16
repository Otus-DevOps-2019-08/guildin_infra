# guildin_infra
guildin Infra repository

#Исследовать способ подключения к someinternalhost в одну
#команду из вашего рабочего устройства, проверить
#работоспособность найденного решения и внести его в
#README.md в вашем репозитории
ssh -i ~/.ssh/gcp_id.rsa -A -J atikhonov.gcp@34.76.12.102 atikhonov.gcp@10.132.0.3

#Дополнительное задание:
Предложить вариант решения для подключения из консоли при
помощи команды вида ssh someinternalhost из локальной
консоли рабочего устройства, чтобы подключение выполнялось по
алиасу someinternalhost
```
xxx$ cat ~/.ssh/config 
Host bastion
	HostName 34.76.108.95
	User atikhonov.gcp
	IdentityFile ~/.ssh/gcp_id_rsa
Host someinternalhost
	HostName 10.132.0.3
	User atikhonov.gcp
	ProxyJump bastion
```

bastion_IP = 34.76.108.95
someinternalhost_IP = 10.132.0.3

#Деплой тестового приложения
##Установка GC SDK:
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
#Prerequisites
apt-get install apt-transport-https ca-certificates
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk

##создание нового экземпляра приложения:
```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --metadata-from-file startup-script=install_n_deploy.sh \
  --restart-on-failure
```

##логин в ВМ reddit-app
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

##Запуск MongoDB, установка службы, проверка
```
sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl status mongod
```

##Deploy
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install 

##Настройка брандмауэра:
-создано правило default-puma-server с тегом puma-server для 0.0.0.0/0 на порт 9292 
-проверена работоспособность веб-интерфейса

##самостоятельная работа
-скрипты install_ruby.sh, install_mongodb.sh, deploy.sh созданы, сделаны исполняемыми
-на их базе сформирован startup_script install_n_deploy.sh:
-проверена его работа на автодеплое экземпляра:
```
gcloud compute instances create reddit-app4\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --metadata-from-file startup-script=install_n_deploy.sh \
  --restart-on-failure
```

##Дополнительное задание
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





# Terraform

##Базовое задание
- Установлен terraform версии 0.12.10
- создан main.tf
- содержимое .gitignore:
```
*.tfstate
*.tfstate.*.backup
*.tfstate.backup
*.tfvars
.terraform/
```
- в main.tf заявлен провайдер google версии 2.15, при инициализации (terraform init)
- в main.tf заявлен экземпляр ВМ на базе созданного ранее образа reddit-base
```
resource "google_compute_instance" "app" {
  name = "reddit-app"
  machine_type = "f1-micro"
  zone = "europe-west1-b"
  boot_disk {
    initialize_params {
      image = "reddit-base"
    }
  }
  
  network_interface {
    network = "default"
    access_config {}
  }
}                    
```
- Изучен вывод terraform plan, создана ВМ через terraform apply (-auto-approve использовать не стал, не стоит привыкать)
- Изучен файл terraform.tfstate, выведены данные через terraform show | grep ...
- ssh appuser@nat_ip (fail)
```
  metadata = {
    ssh-keys = "appuser:${file(~/.ssh/appuser.pub)"
  }
```
- terraform plan && terraform apply
- ssh -i ~/.ssh/appuser appuser@nat_ip (OK)
- создан файл для outputs переменных
```
output "app_external_ip" {
  value = google_compute_instance.app.network_interface[0].access_config[0].nat_ip
}
```
-  добавлено правило брандмауэра:
```
resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["reddit-app"]
}
```
- ...и применено к ВМ: 
resource "google_compute_instance" "app" {
...
tags = ["reddit-app"]
...
}
- с помощью провиженера file описан файл для передачи на ВМ:
```
provisioner "file" {
source = "files/puma.service"
destination = "/tmp/puma.service"
}
```
(вообще это делалось на предыдущей практике, но сделать еще раз несложно)
- mkdir files && vim files\puma.service:
```
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/home/appuser/reddit
ExecStart=/bin/bash -lc 'puma'
Restart=always

[Install]
WantedBy=multi-user.target
```
- Создан files/deploy.sh
```
#!/bin/bash
set -e
APP_DIR=${1:-$HOME}
git clone -b monolith https://github.com/express42/reddit.git $APP_DIR/reddit
cd $APP_DIR/reddit
bundle install
sudo mv /tmp/puma.service /etc/systemd/system/puma.service
sudo systemctl start puma
sudo systemctl enable puma
```
- Добавлен соответствующий провиженер
```
provisioner "remote-exec" {
script = "files/deploy.sh"
}
```
- для подключения провиженера к ВМ при развертывании добавлены параметы подключения:
```
resource "google_compute_instance" "app" {
...
connection {
type = "ssh"
host = self.network_interface[0].access_config[0].nat_ip
user = "appuser"
agent = false
# путь до приватного ключа
private_key = file("~/.ssh/appuser")
}
...
}

```
- terraform taint google_compute_instance.app && terraform plan && terraform apply
- проведена проверка работоспособности приложения на ВМ
- В файл variables.tf вынесен ряд параметров
(пример)
```
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}
```
- Переменные могут иметь дефолтное значение, или не иметь. Тогда перечисляем необходимые значения в файле terraform.tfvars
```
project          = "infra-xxxxxx"
public_key_path  = "~/.ssh/appuser.pub"
private_key_path = "~/.ssh/appuser"
disk_image       = "reddit-base"
```
- terraform destroy && terraform plan && terraform apply
OK.

##Самостоятельное задание
- Определите input переменную для приватного ключа, использующегося в определении подключения для провижинеров (connection);
variables.tf:
...
variable private_key_path {
  description = "Path to the private key used for ssh access"
}
...
terraform.tfvars:
...
private_key_path = "~/.ssh/appuser"
...
- Определите input переменную для задания зоны в ресурсе "google_compute_instance" "app". У нее должно быть значение по умолчанию;
variables.tf:
...
variable zone {
  description = "zone to deploy in"
  # Значение по умолчанию
  default = "europe-west1-b"
}
...
- Форматирование файлов конфигурации: terraform fmt - OK
- В terraform.tfvars.example указаны переменные для образца  

##Задание со *
###1
- Опишите в коде терраформа добавление ssh ключа пользователя appuser1 в метаданные проекта. Выполните terraform apply и проверьте результат (публичный ключ можно брать пользователя appuser)
```
  metadata = {
    ssh-keys = "appuser1:${file(var.public_key_path)}"
  }
```
- Опишите в коде терраформа добавление ssh ключей нескольких пользователей в метаданные проекта (можно просто один и тот же публичный ключ, но с разными именами пользователей, например appuser1, appuser2 и т.д.). Выполните terraform apply и проверьте результат
```
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)} \nappuser1:${file(var.public_key_path)} \nappuser2:${file(var.public_key_path)}"
  }
```
###2
- Добавлен ssh ключ [appuser_web] в консоли CGP, осуществлен вход через ssh, запущен terraform apply:
google_compute_firewall.firewall_puma: Refreshing state... [id=allow-puma-default]
google_compute_instance.app: Refreshing state... [id=reddit-app]
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
Outputs:
app_external_ip = ...
terraform никак не реагирует на появление нового ключа.  

##Задание с **
###Балансировщик
- Создан файл lb.tf (изначально описал ВМ с балансировщиком на nginx > позднее переименовал его в lb.tf-nginx)
- В lb.tf описаны ресурсы, формирующие инфраструктуру балансировщика google
- Проведена проверка.
- добавлен код reddit-app2 (файл reddit-app2.tf), машина добавлена в группу:
```
lb.tf
resource "google_compute_instance_group" "default" {
...
  instances = [
    ...
    "${google_compute_instance.app2.self_link}",
  ]
...
 }
```
- Проведена проверка балансировщика. Полный destroy && apply && http

### VM count
- файл reddit-app2.tf > reddit-app2.tf-history 
- в main.tf в описание ВМ:
```
name = "reddit-app-${count.index + 1}"
count        = var.vmcount
```
- В variables.tf:
```
variable vmcount {
  description = "Number of instances"
  default     = "1"
}
```
- validate && plan && apply
Создана инфраструктура с 1 ВМ в группе. А, точно! В lb.tf:
```
resource "google_compute_instance_group" "default" {
...
  instances   = "${google_compute_instance.app[*].self_link}"
...
}
```
- Теперь добавим еще инстанс поверх. В terraform.tfvars изменим дефолтный var.vmcount:
```
vmcount          = "2"
```
- validate && plan && apply - OK. Развернуты 2 экземпляра.

