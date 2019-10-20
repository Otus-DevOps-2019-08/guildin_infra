# guildin_infra
guildin Infra repository

# Курс DevOps 2019-08. Бортовой журнал. 
Задания со звездочкой отмечаются в журнале литерой *Ж*. Во-первых, символ _астериск_ занят, а во-вторых это немного символично. Самую малось, разумеется.

# Содержание (under construction)

| [Terraform-1](#terraform-1) | Базовое задание | [TF1 Задание Ж](#tf1-задание-ж) | ЖЖ  |
| --- | --- | --- | --- |
| [Terraform-2](#terraform-2) | [TF2 Управление брандмауэром](#tf2-управление-брандмауэром) | [TF2. Самостоятельное задание](#tf2-самостоятельное-задание) | [TF2 Задание Ж](#tf2-задание-ж) <br> [TF2 Задание ЖЖ](#tf2-задание-жж) |


# Bastion-host
Подключение к экземпляру ВМ, не имеющему внешнего адреса может быть выполнено через bastion-host:
ssh -i ~/.ssh/gcp_id.rsa -A -J atikhonov.gcp@34.76.12.102 atikhonov.gcp@10.132.0.3

## Дополнительное задание:
Предложить вариант решения для подключения из консоли припомощи команды вида _ssh someinternalhost_ из локальной
консоли рабочего устройства, чтобы подключение выполнялось по алиасу _someinternalhost_
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
Отладочная информация
bastion_IP = 34.76.108.95
someinternalhost_IP = 10.132.0.3

# Основные сервисы Google Cloud Platform.
## Деплой тестового приложения. Подготовка ВМ
  * Установка GC SDK:
```
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
#Prerequisites
apt-get install apt-transport-https ca-certificates
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk
```
  * Cоздание нового экземпляра приложения:
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
### логин в ВМ reddit-app
  * установка ruby 
```sudo apt update && sudo apt install -y ruby-full ruby-bundler build-essential```
  * Проверка ruby (ruby -v) >>> ruby 2.3.1p112 (2016-04-26) [x86_64-linux-gnu]
  * Проверка bundler (bundler -v) >>> Bundler version 1.11.2

### Установка MongoDB
```
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
sudo apt update
sudo apt install -y mongodb-org
```
### Запуск MongoDB, установка службы, проверка
```
sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl status mongod
```

### Reddit Deploy
```
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install 
```
### Настройка брандмауэра:
  * создано правило default-puma-server с тегом puma-server для 0.0.0.0/0 на порт 9292 
  * проверена работоспособность веб-интерфейса

## Деплой тестового приложения. Самостоятельная работа
  * скрипты install_ruby.sh, install_mongodb.sh, deploy.sh созданы, сделаны исполняемыми
  * на их базе сформирован startup_script install_n_deploy.sh:
  * проверена его работа на автодеплое экземпляра:
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

## Деплой тестового приложения. Дополнительное задание
 default-puma-server - удалить и создать заново
  * смотрим что есть:
```gcloud compute firewall-rules list```
  * удаляем default-puma-server
```gcloud compute firewall-rules delete default-puma-server```
  * проверяем коннект - нет, создаем новое правило:
```gcloud compute firewall-rules create default-puma-server --allow tcp:9292 --source-tags=puma-server --source-ranges=0.0.0.0/0```
  * Ждем некоторое время... Profit!

Отладочная информация
testapp_IP = 104.155.111.133 
testapp_port = 9292 


# Сборка образов VM при помощи Packer

## Packer Базовое задание
- Установлен packer (packer.io), создан ADC для авторизации:
gcloud auth application-default login
- созданы шаблон и файл уточнений для него: ubuntu16.json и variables.json[.example]; с помощью packer validate проверена корректность синтаксиса
Данные файлы описывают образ ВМ ubuntu-1604-lts с установленными ruby и mongodb
- используя вышеуказанные файлы сформирован образ reddit-base-[дата] семейства reddit-base (наименования условные) 

## Самостоятельное задание
- Файл с переменными variables.json, внесен в .gitignore
- Пользовательские данные выведены в variables.json
- variables.json.example

## Задание со Ж
- На основе шаблона reddit-base создан шаблон immutable.json (семейство reddit-full). Данный шаблон описывает развертывание на базовом шаблоне puma server.
- puma.service описывает запуск сервиса через systemd.unit
- Сценарий create-redditvm.sh написан. 


# Terraform 1

## TF1 Базовое задание
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

## Самостоятельное задание
Определите input переменную для приватного ключа, использующегося в определении подключения для провижинеров (connection);
variables.tf:
```
variable private_key_path {
  description = "Path to the private key used for ssh access"
}
```
terraform.tfvars:
```
private_key_path = "~/.ssh/appuser"
```
Определите input переменную для задания зоны в ресурсе "google_compute_instance" "app". У нее должно быть значение по умолчанию;
variables.tf:
```
variable zone {
  description = "zone to deploy in"
  # Значение по умолчанию
  default = "europe-west1-b"
}
```
Форматирование файлов конфигурации: 
```terraform fmt```

В terraform.tfvars.example указаны переменные для образца  

## TF1 Задание Ж
добавление ssh ключей
Опишите в коде терраформа добавление ssh ключа пользователя appuser1 в метаданные проекта. Выполните terraform apply и проверьте результат (публичный ключ можно брать пользователя appuser)
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

### ключи, добавленные через консоль
Добавлен ssh ключ [appuser_web] в консоли CGP, осуществлен вход через ssh, запущен terraform apply:
google_compute_firewall.firewall_puma: Refreshing state... [id=allow-puma-default]
google_compute_instance.app: Refreshing state... [id=reddit-app]
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
Outputs:
app_external_ip = ...
terraform никак не реагирует на появление нового ключа.  

## TF1 Задание ЖЖ
### Балансировщик
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

Теперь добавим еще инстанс поверх. В terraform.tfvars изменим дефолтный var.vmcount:
```
vmcount          = "2"
```

validate && plan && apply - OK. Развернуты 2 экземпляра.



# terraform-2
## TF2 Управление брандмауэром
Удалим правило, разрешающее ssh по умолчанию, и создадим свое:
```
resource "google_compute_firewall" "firewall_ssh" {
  name = "default-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
```

Применим изменения (terraform apply). Ошибки не будет, потому что мы уже удалили дефолтное правило. Да, я немного забежал вперед.
NB! Мы также можем скормить терраформу информацию о том или ином имеющемся правиле, сгенерированном не через TF
```
terraform import google_compute_firewall.firewall_ssh default-allow-ssh
```

## TF2. Взаимосвязи ресурсов. Часть 1. IP адрес
- Создадим статический адрес. В main.tf:
```
resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}
```
GCP по умолчанию дает нам создать только один адрес, поэтому если у нас уже есть таковой (VPC Network -> external ip addresses), от него придется избавиться. Или перейдти на другой план ;)
- После указания нового ресурса они начнут создаваться параллельно. 
- Сошлемся на новый статический адрес в ВМ app:
```
network_interface {
 network = "default"
 access_config {
   nat_ip = google_compute_address.app_ip.address
 }
}
...
```
  * Пересоздадим ресурсы и убедимся, что ВМ app начинает создаваться только после создания ресурса _google_compute_address app_ip_

##Несколько ВМ -> модули
- Создадим в ../packer шаблоны app.json и db.json
- Опишем в них установку соотвественно ruby и mongoDB
app.json
```
{
    "builders": [
        {
            "type": "googlecompute",
            "project_id": "{{user `project_id`}}",
            "image_name": "reddit-app-base",                          # Образ APP
            "image_family": "reddit-base",
            "source_image_family": "{{user `source_image_family`}}",
            "zone": "europe-west1-b",
            "ssh_username": "{{user `ssh_username`}}",
            "machine_type": "{{user `machine_type`}}",
            "image_description": "REDDIT APP",
            "disk_size":"{{user `disk_size`}}",
            "disk_type":"{{user `disk_type`}}",
            "network":"{{user `network`}}",
            "tags":"{{user `tags`}}"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "file",
            "source": "files/puma.service",
            "destination": "/tmp/puma.service"
        },
        {
            "type": "shell",
            "script": "files/deploy.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}
```
Файл db.json:
```
{
    "builders": [
        {
            "type": "googlecompute",
            "project_id": "{{user `project_id`}}",
            "image_name": "reddit-db-base",i                           # Образ DB
            "image_family": "reddit-base",
            "source_image_family": "{{user `source_image_family`}}",
            "zone": "europe-west1-b",
            "ssh_username": "{{user `ssh_username`}}",
            "machine_type": "{{user `machine_type`}}",
            "image_description": "{{user `image_description`}}",
            "disk_size":"{{user `disk_size`}}",
            "disk_type":"{{user `disk_type`}}",
            "network":"{{user `network`}}"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}
```
...Мы не стали пренебрегать провиженерами. Во-первых это несложно, во-вторых инфраструктура будет взлетать существенно быстрее, а когда делаешь apply | destroy | apply многократно, это существенно экономит время.

- Опишем конфигурации ВМ в терраформе:
  * APP
```
resource "google_compute_instance" "app" {
  name = "reddit-app"
  machine_type = "f1-micro"  # а не g1-small ))
  zone = var.zone
  tags = ["reddit-app"]
  boot_disk {
    initialize_params { image = var.app_disk_image }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.app_ip.address
    }
  }
  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_address" "app_ip" { 
  name = "reddit-app-ip" 
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp", ports = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["reddit-app"]
}

```


  * DB
```
resource "google_compute_instance" "db" {
  name = "reddit-db"
  machine_type = "g1-small"
  zone = var.zone
    tags = ["reddit-db"]
    boot_disk {
    initialize_params {
      image = var.db_disk_image
    }
  }
  network_interface {
    network = "default"
    access_config = {}
  }
  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
 }

 resource "google_compute_firewall" "firewall_mongo" {
  name = "allow-mongo-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports = ["27017"]
  }
  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}
```
  * Не забудем указать переменные с именами образов в variables.tf
```
variable app_disk_image {
  description = "Disk image for reddit app"
  default = "reddit-app-base"
}
variable db_disk_image {
  description = "Disk image for reddit db"
  default = "reddit-db-base"
}

```
  * Вынесем правила файерфвола в отдельный файл vpc.tf и переместим правила брандмауэра туда
  * В main.tf осталось немного:
```
provider "google" {
  version = "2.15"
  project = var.project
  region  = var.region
}
```
## TF2 Модули
- Создадим каталог modules и подкаталоги экземпляров
```
mkdir modules
mkdir modules/app
mkdir modules/db
mkdir modules/vpc
```
  * Перенесем туда уже выделенные экземпляры:
```
mv app.tf modules/app
mv db.tf modules/db
mv vpc.tf modules/vpc
```

  * Используемые в экземплярах переменные рассуем по файлам variables.tf 
  * И outputs:
```
# ../modules/app/outputs.tf
output "app_external_ip" {
  value = google_compute_instance.app.network_interface.0.access_config.0.assigned_nat_ip
}

...

# ../modules/db/outputs.tf
output "internal_ip" {
  value = google_compute_instance.db[*].network_interface[0].network_ip
}

```
  * Аналогично создаем модуль vpc в ../modules/vpc/main.tf	
  * Создадим инфраструктуру и проверим запуск ВМ

##TF2. Самостоятельное задание
  * Внесем в модуль vpc изменения:
```
module "vpc" {
  source = "modules/vpc"
  source_ranges = ["8.8.8.8/32"]
}
```
- Применим изменения. Попробуем зашеллиться в созданную вм, ничего не сможем...
- поменяем 8.8.8.8 на свой ip и, после примения изменений зашеллимся успешно.
- ...Работает. Вернем 0.0.0.0/0

##Переиспользование модулей
- Создадим каталоги stage и prod
- Скопируем в них файлы main.tf, variables.tf, outputs.tf, terraform.tfvars
- Не забудем поменять пути к модулям на валидные:
```
module "app" {
  source          = "../modules/app"
  public_key_path = var.public_key_path
  zone            = var.zone
  app_disk_image  = var.app_disk_image
}

module "db" {
  source          = "../modules/db"
  public_key_path = var.public_key_path
  zone            = var.zone
  db_disk_image   = var.db_disk_image
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["0.0.0.0/0"]
}

```
### Модули. Самостоятельное задание
- Удалим старые файлы конфигурации из корневой папки
- Поменяем конфигурацию модулей, добавляя / удаляя переменные, указывая их в конфигурации
- Отформатируем файлы terraform fmt

## TF2 Задание Ж
### Хранение стейт файла в удаленном бекенде для окружений stage и prod
Google Cloud Storage в качестве бекенда. 
Референс здесь: https://registry.terraform.io/modules/SweetOps/storage-bucket/google/0.3.0

- Инициализация бакета: Файл storage-bucket.tf
```
module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.3.0"

  # Имя поменяйте на другое
  name = "backet00"                    #можно сказать, имя собственное
  namespace   = "eu"                   #Тут я не совсем разобрался, можно ли указывать что угодно, похоже на геозону
  stage = "test"                       # А вот это похоже mandatory: 'prod', 'staging', 'dev' или 'source', 'build', 'test', 'deploy', 'release'
  storage_class      = "NEARLINE"      #MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE. Что бы это значило
  project = var.project
  location      = var.region

}

output storage-bucket_url {
  value = module.storage-bucket.url
}
```
  * terraform init && terraform plan && terraform apply
  * Описание бекенда нужно вынести в отдельный файл backend.tf (по файлу в каждое окружение):
```
terraform {
  backend "gcs" {
    bucket  = "eu-test-backet00"
    prefix  = "terraform/<ENV>" # (stage | prod)
  }
} 
```
  * _terraform init && terraform plan && terraform apply_ # для каждого окружения. _terraform destroy_, конечно

###2. 
Перенесите конфигурационные файлы Terraform в другую директорию (вне репозитория). Проверьте, что state-файл
(terraform.tfstate) отсутствует. Запустите Terraform в обеих директориях и проконтролируйте, что он "видит" текущее
состояние независимо от директории, в которой запускается
- Без backend.tf терраформ состояние не показывает.  Отсутствие же прочих *.tf его не смущает. Файл .tfstate успешно создался в бакете. В обоих окружениях.

###3. 
Попробуйте запустить применение конфигурации одновременно, чтобы проверить работу блокировок
```
Error: Error creating Address: googleapi: Error 409: The resource 'projects/infra-253310/regions/europe-west1/addresses/reddit-app-ip' already exists, alreadyExists
  on ..\modules\app\main.tf line 19, in resource "google_compute_address" "app_ip":
  19: resource "google_compute_address" "app_ip" {
Error: Error creating instance: googleapi: Error 409: The resource 'projects/infra-253310/zones/europe-west1-b/instances/reddit-db' already exists, alreadyExists
  on ..\modules\db\main.tf line 1, in resource "google_compute_instance" "db":
   1: resource "google_compute_instance" "db" {
```

## TF2 Задание ЖЖ 
В процессе выполнения предыдущих задач были выпечены (слава пакеру!) образы reddit-app-base и reddit-db-base.
Это существенно ускорило работу terraform apply
Однако ссылки на базы данных у сервера приложения нет, да и конфигурация самой базы данных - в умолчальном состоянии.
Поэтому работа провижинеров призвана обеспечить необходимые изменения:
  * Для начала, app-экземпляру необходимо узнать адрес db-экземпляра. Как мы помним, конфигуация файервола для db-экземляра разрешает трафик тегированных reddit-app ВМ (не нат!) на reddit-db ВМ.
```
resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
  target_tags = ["reddit-db"] # - правило применяется к ВМ тегированным указанным тегом
  source_tags = ["reddit-app"] # - разрешается трафик с внутренних интерфейсов машин с указанным тегом. Логично.
}
```
Для этого положим его в output переменную ../modules/db/outputs.tf:
```
output "internal_ip" {
  value = google_compute_instance.db[*].network_interface[0].network_ip
}
```
...И сделаем ссылку в материнской конфигурации outputs.tf:
```
output "db_addr" {
  value = module.db.internal_ip
}
```
Наконец, упомянем его в конфигурации модуля app в материнской конфигурации:
```
module "app" {
...
  db_addr         = module.db.internal_ip
}
```
  * Теперь нам необходимы провижинеры:
Для app:
```
resource "null_resource" "post-install" {
  connection {
    type        = "ssh"
    host        = google_compute_address.app_ip.address
    user        = "appuser"
    agent       = false
    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo echo DATABASE_URL=${var.db_addr.0} > /tmp/grab.env",                                   #  Вот он, вон он адрес СУБД, положим его куда попало
      "sudo sed -i '/Service/a EnvironmentFile=/tmp/grab.env' /etc/systemd/system/puma.service",   #  ...и сошлемся на это самое куда попало в юнит файле,
      "sudo systemctl daemon-reload",                                                              #  ...расскажем об этом systemd
      "sudo service puma restart",                                                                 #  перезагрузим сервис для применения новых настроек.
    ]
  }

```

Для db
```
... # опустим описание нуль-ресурса post-install
  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf",   # Тут все проще. Заменим петлевой адрес на любой имеющийся (0.0.0.0) (Bind IP) 
      "sudo service mongod restart",                            # и рестартуем службу.
    ]
  }
```
  * NB! В данном случае нам не понадобилось размещение в директориях модулей каких-либо файлов, но если такая необходимость возникнет, то путь к ним начинается c ${path.module}
  * NB! Выведение провиженера в нуль-ресурс - очень важный архитектурный момент, если что-то  в процессе идет не так, то taint и пересоздание происходит нуль-ресурса, а не экземпляра ВМ
