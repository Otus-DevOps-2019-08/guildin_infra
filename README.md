# guildin_infra

guildin Infra repository

# Курс DevOps 2019-08. Бортовой журнал. 
Задания со звездочкой отмечаются в журнале литерой *Ж*. Во-первых, символ _астериск_ занят, а во-вторых это немного символично. Самую малось, разумеется.

# Содержание (under construction)

| [Terraform-1](#terraform-1) | Базовое задание | [TF1 Задание Ж](#tf1-задание-ж) | ЖЖ  |
| --- | --- | --- | --- |
| [Terraform-2](#terraform-2) | [TF2 Управление брандмауэром](#tf2-управление-брандмауэром) | [TF2. Самостоятельное задание](#tf2-самостоятельное-задание) | [TF2 Задание Ж](#tf2-задание-ж) <br> [TF2 Задание ЖЖ](#tf2-задание-жж) |
| --- | --- | --- | --- |
| [Ansible-1](#ansible-1) | Базовое задание | [A1 Задание Ж](#a1-задание-ж) | ЖЖ  |
| --- | --- | --- | --- |
| [Ansible-2](#ansible-2) | Базовое задание | [A2 Задание Ж](#a2-задание-ж) | [Ansible-2 packer](#ansible-2-packer)  |
| --- | --- | --- | --- |
| [Ansible-3](#ansible-3) | [Ansible-galaxy](ansible-galaxy) | [A3 Задание Ж](#a3-задание-ж) | [Ansible-vault](#ansible-vault)  |

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

# Ansible-1

## Установка ansible
sudo apt install python-pip
echo "ansible>=2.4" > requirements.txt
pip install -r requirements.txt

Не катит. Тогда:
```
sudo apt-get install python-setuptools ansible
```
apt без вопросов поставит ansible 2.2, а потом накатываем через этот ваш pip версию больше 2.4, а конкретно ansible 2.8.6.

  * Развернем stage версию окружения:
```cd ../terraform/stage && terraform apply```
  * Получим outputs и:
~/  ansible$ echo "appserver ansible_host=X.X.X.X ansible_user=appuser ansible_private_key_file=~/.ssh/appuser" > inventory


тестовый запуск:
```
ansible appserver -i ./inventory -m ping
The authenticity of host '23.251.128.237 (23.251.128.237)' can't be established.
ECDSA key fingerprint is SHA256:zXR27pcxoeZYnOZZVoKqT3UI39qR6zqYH8J/0AE17Po.
Are you sure you want to continue connecting (yes/no)? yes
[DEPRECATION WARNING]: Distribution Ubuntu 16.04 on host appserver should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior 
Ansible releases. A future Ansible release will default to using the discovered platform python for this host. See 
https://docs.ansible.com/ansible/2.8/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12. Deprecation 
warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
appserver | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}

```

по аналогии добавим данные для подключения к северу БД
```
dbserver ansible_host=Y.Y.Y.Y ansible_user=appuser ansible_private_key_file=~/.ssh/appuser
```
Зададим настройки для подключения по умолчанию (ansible.cfg):
```
[defaults]
inventory = ./inventory
remote_user = appuser
private_key_file = ~/.ssh/appuser
host_key_checking = False
retry_files_enabled = False
```
После этого приведем inventory к следующему виду:
```
appserver ansible_host=X.X.X.X
dbserver ansible_host=Y.Y.Y.Y
```

Проверим работу:
```ansible dbserver -m command -a uptime```
[DEPRECATION WARNING]: Distribution Ubuntu 16.04 on host dbserver should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior 
Ansible releases. A future Ansible release will default to using the discovered platform python for this host. See 
https://docs.ansible.com/ansible/2.8/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12. Deprecation 
warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
dbserver | CHANGED | rc=0 >>
 21:52:11 up 14 min,  1 user,  load average: 0.00, 0.02, 0.06

### Ansible. Работа с группами хостов
[app]
appserver ansible_host=23.251.128.237 
dbserver ansible_host=34.77.203.234 

Проверка:
```ansible app -m ping```

### [Документация по  inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)


ansible app -m _command_ -a 'ruby -v; bundler -v' -i inventory.yml - _ не сработает_
ansible app -m shell -a 'ruby -v; bundler -v' -i inventory.yml - _сработает_
Модуль command выполняет команды, не используя оболочку(sh, bash), поэтому в нем не работают перенаправления потокови нет доступа к некоторым переменным окружения.

### Выполнение команд
  * 
```ansible db -m *command* -a 'systemctl status mongod' -i inventory.yml```
```ansible db -m *systemd* -a name=mongod -i inventory.yml```
```ansible db -m *service* -a name=mongod -i inventory.yml```
  * Установка git:
```ansible app -m git -a 'repo=https://github.com/express42/reddit.git dest=/home/appuser/reddit'```
При повторном запуске возвращает результат SUCCESS c параметром changed: false
### Первый плейбук:
```
---
- name: Clone
  hosts: app
  tasks:
    - name: Clone repo
      git:
        repo: https://github.com/express42/reddit.git
        dest: /home/appuser/reddit
```

Попробуем запустить:
```ansible-playbook clone.yml```
appserver                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
--- Второй запуск
```ansible-playbook clone.yml```
appserver                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
--- Третий запуск после удаления на целевой группе папки реддит
```ansible app -m command -a ' rm -rf ~/reddit' && ansible-playbook clone.yml```
appserver                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


## A1 Задание Ж
[Заметка про json в ансибл (или наоборот)](https://medium.com/@Nklya/%D0%B4%D0%B8%D0%BD%D0%B0%D0%BC%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%BE%D0%B5-%D0%B8%D0%BD%D0%B2%D0%B5%D0%BD%D1%82%D0%BE%D1%80%D0%B8-%D0%B2-ansible-9ee880d540d6)
  * Попробуем сформировать json inventory с подобной структурой: 
```
{
  "all": {
    "children": {
    "apps": {
        "hosts": {
          "35.241.204.244": null
        }
      },
      "dbs": {
        "hosts": {
          "23.251.128.237": null
        }
      }
    }
  }
}
```
  * Тестирование:
```ansible -i static-inv.json all -m ping```
Что же, статическое inventory работает.

  * Для динамического inventory используем GCP плагин для ansible (далее inventory.gcp.yml):
```
plugin: gcp_compute
auth_kind: serviceaccount
service_account_file: "~/.ssh/infra-40b9617a4128.json" #credential, полученный через консоль. Через gcloud tool не стал, не так то часто забираешь ключи от машины.
regions:
  - eu-west1-b
projects:
  - infra-253310
hostnames:
  - public_ip # Из какого тега забрать имя хоста
compose:
  ansible_host: networkInterfaces[0].accessConfigs[0].natIP
```

  * Сошлемся на него в ansible.cfg, чтобы каждый раз не указывать. Можно даже попробовать:
```ansible all --list```
  hosts (2):
    35.241.204.244
    23.251.128.237
Это замечательно, это работает, это не json. Ну хорошо. ansible-inventory умеет в json:
```ansible-inventory --export --list``` > inventory.json
Да, мы сразу положили все-все-все в файл. Но значимые данные на текущий момент имеют следующую структуру:
```json
{
    "_meta": {
        "hostvars": {
            "23.251.128.237": {                         
                "ansible_host_natip": "23.251.128.237", 
                "name": "reddit-db", 
                "project": "infra-253310", 
                "tags": {
                    "items": [
                        "reddit-db"
                    ]
                }, 
                "zone": "europe-west1-b", 
            }, 
            "35.241.204.244": {
                "ansible_host_natip": "35.241.204.244", 
                "name": "reddit-app", 
                "project": "infra-253310", 
                "tags": {
                    "items": [
                        "http-server", 
                        "reddit-app"
                    ]
                }, 
                "zone": "europe-west1-b", 
            }
        }
    }, 
    "all": {
        "children": [
            "ungrouped"
        ]
    }, 
    "ungrouped": {
        "hosts": [
            "23.251.128.237", 
            "35.241.204.244"
        ]
    }
}
```

В соответствии со статьей нужно сделать следующее:
1. Динамическое инвентори представляет собой простой исполняемый скрипт (+x), который при запуске с параметром --list возвращает список хостов в формате JSON.
2. При запуске скрипта с параметром --host <hostname> (где <hostname> это один из хостов), скрипт должен вернуть JSON с переменными для этого хоста. Поддержка этой опции необязательно, скрипт может просто вернуть пустой список. 

Для работы с json возьмем утилиту jq.
Ей передадим inventory.json, формирующийся с помощью плагина gcp_compute (подробнее в файле inventory.gcp.yml)
На основе данных из inventory.json формируется статический json, который может быть использован в качестве -i <inventory> ansible
### json-i.sh
```
#!/bin/bash
function getHost () {
	if [[ -n $1 ]]
	then
		printf "getting data for host $1  \n"
		ansible-inventory -i inventory.gcp.yml --output inventory.json
		cat inventory.json | jq '._meta.hostvars['\"$1\"']' > inventory.json
	else
		printf "No hostname specified!"
	fi
	}

function getList() {
	ansible-inventory -i inventory.gcp.yml --output inventory.json
	printf "{\n" 
	printf "    \"all\": {\n"
	printf "         \"children\":{\n"
	
#имплементация группировки хостов. В данной работе предпочту не реализовывать.
#Вместо этого возьму hostname и сделаю вид, что так и было.
#Да, будет ругаться на дефисы. Все равно будет, можно было бы sed 's/-//g'
	cat inventory.json |  jq '._meta' | jq '.hostvars' | jq '.[]' | jq '.name' > fill.arr
	i=0
	while read line
	do
		HOSTS[$i]="$line"
		i=$(($i+1))
	done < fill.arr
	rm fill.arr
	
	i=0
	cat inventory.json |  jq '._meta' | jq '.hostvars' | jq '.[]' | jq '.networkInterfaces' | jq '.[0]' | jq '.accessConfigs' | jq '.[0]' | jq '.natIP' > IPs.arr	
	while read line
	do
		IPs[$i]="$line"
		i=$(($i+1))
	done < IPs.arr
	rm IPs.arr
	
	j=0
	for h in "${HOSTS[@]}"
	do
		printf "        ${HOSTS[$j]}: {\n                 \"hosts\": {\n" 
		printf "${IPs[$j]}: null }\n"
	
		if [[ $((i-j)) > 1 ]]; then printf "},\n"; else printf "}\n"; fi 
		j=$(($j+1))
	done	
			printf "             }\n       }\n}\n"
	
	

	}

echo
while [ -n "$1" ]
do
	case "$1" in
		--list) getList ;;
		--host) getHost $2 ;;
		--help) printf "usage: json-i.sh ARGS\n --list - перечень хостов в инвентори \n --host [hostname] - выдать json-данные по этому хосту.\n";;
	esac
	shift
done
```

### Пасхалочка для Lisskha. А нефиг.
```diff
- text in red
+ text in green
! text in orange
# text in gray
```


# Ansible-2
Подготовка к работе. Заплакал и закомментировал провижинеры в терраформ. Шутка, мне они никогда не нравились. В пакере я готовил образ с нужным софтом для быстрого развертывания, в терраформ их развертывал, а конфигурацию всегда хотел в ансибл.
## Плейбуки
Создадим файл reddit_app.yml, по сути являющийся плейбуком. Разберем подробнее:
cat reddit_app.yml 
```
---
- name: Configure hosts & deploy application # < Пространные имена слегка непривычны, так и хочется обозвать из описанием, но поди ж ты.
  hosts: all                                 # < 
  vars:
    mongo_bind_ip: 0.0.0.0                   # < должен быть словарь, ключ: значение | в нашем случае объявляем значение переменной, определенной в шаблоне
  tasks:                                     # < Собственно, задачи плейбука
  - name: Change mongo config file           # < Что ж имена то так описательно выглядят ((
    become: true                             # < По существу: выполнять с повышением прав.
    template:                                
      src: templates/mongod.conf.j2          # Я удивлен, что шаблон не надо обзывать пространно. Пытался, не вышло. А вот источник указывать надо, не отвертишься.
      dest: /etc/mongod.conf                 # Как и назначение. В нашем случае файл. Ой, да в unix все файл.
      mode: 0644                             # Ненавижу эти маски. Когда же я в них разберусь?!
  tags: db-tag # <-- Список тэгов для задачи # !!! Узнать, куда собачить тег. Собственно, фильтрация, не будем же мы на фронтэнд это пихать?
```

## Шаблоны
```
cat templates/mongod.conf.j2       # *.j2 conventionally обозначает что мы делаем шаблон. Это для нас, не для обработчика.
storage:
  dbPath: /var/lib/mongodb               # Куда
  journal:
    enabled: true                      

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

net:                                               #настройка сокета
  port: {{ mongo_port | default('27017') }}        # порт (mongo в данном случае) Смотрите, сразу определили значение по умолчанию
  bindIp: {{ mongo_bind_ip }}                      # адрес прослушивания. Здесь дефолтного значения нет, так что без указания этого в плейбуке мы ничего не сделаем. 

## Прогон плейбука
```ansible-playbook reddit_app.yml --check --limit db```

PLAY [Configure hosts & deploy application] *****************************************************************************************************************************
TASK [Gathering Facts] **************************************************************************************************************************************************
ok: [dbserver]
TASK [Change mongo config file] *****************************************************************************************************************************************
changed: [dbserver]
PLAY RECAP **************************************************************************************************************************************************************
dbserver                   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

## Handlers // ну где же ваши ручки, давай поднимем ручки - так делать будут таски. Сорян-борян, это stage кусок документации. 
Handlers  похожи  на  tasks,  однако  запускаются  только  по оповещению от других задач. Говоря своими словами, не являются самостоятельной сущностью, дочерни.
Запишем это в плейбук:
```
...
    notify: restart mongod # Эта строка относится к области действия одной из описанных задач. Она и содержит линк на имя хэндлера, который будем прогонять по факту выполнения задачи.
...

  handlers:
  - name: restart mongod                     # вызывали?
    become: true                             # режим господина.
    service: name=mongod state=restarted     # суть выполняемых действий.

```

## Прогон плейбука

```ansible-playbook reddit_app.yml --check --limit db```
dbserver                   : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


## Настройка инстанса приложения
```
---
...
  vars:
    mongo_bind_ip: 0.0.0.0 
    db_host: 10.132.0.5                   # Сюда - адрес сервера БД
  tasks:
в  - name: Change mongo config file
    become: true
    template:
      src: templates/mongod.conf.j2
      dest: /etc/mongod.conf
      mode: 0644
    tags: db-tag # <-- Список тэгов для задачи
    notify: restart mongod
  - name: Add unit file for Puma
    become: true
    copy:
      src: files/puma.service
      dest: /etc/systemd/system/puma.service
      tags: app-tag
      notify: reloadpuma
  - name: Add config for DB connection
    template:      
      src: templates/db_config.j2
      dest: /home/appuser/db_config
      tags: app-tag
  - name: enable puma
    become: true
    systemd: name=puma enabled=yes
    tags: app-tag

  handlers:
  - name: restart mongod
    become: true
    service: name=mongod state=restarted
  - name: reload puma
    become: true
    systemd: name=puma state=restarted
```

## Деплой
Используем модули git и bundle:
```
  - name: Fetch the latest version of application code
    git:
      repo: 'https://github.com/express42/reddit.git'
      dest: /home/appuser/reddit
      version: monolith 
    tags: deploy-tag
    notify: reload puma
  - name: Bundle install
    bundler:
      state: present
      chdir: /home/appuser/reddit
    tags: deploy-tag    
```
Проверим:  ansible-playbook reddit_app.yml --check --limit app --tags deploy-tag
Выполним: ansible-playbook reddit_app.yml --limit app --tags deploy-tag

## reddit_app_multiple_plays
(в девичестве reddit_app2.yml) по сути дела немного оптимизированный сценарий reddit_app.yml в нем задачи сгруппированы и их параметры обобщены. 
Отладка и проверка проведена успешно.

## site.yml
АКА несколько сценариев. Задачи плейбука растащены по отдельным файлам, и сразу же приступаем к Ж-задаче:
И да:
```
mv reddit_app.yml reddit_app_one_play.yml
mv reddit_app2.yml reddit_app_multiple_plays.yml
``

# A2 Задание Ж
В предыдущем разделе журнала был представлен кривой, в но в целом рабочий генератор inventory в формате json. К моменту формирования второй версии плейбука (reddit_app_multiple_plays.yml) дергание за хосты окончательно надоело и я решил вернуться к динамике. Работа после этого выглядела примерно так:
```
terraform destroy && terraform apply
...

 2001  ./json-i.sh --list > jinventory.json 
 2002  ansible-playbook -i jinventory.json reddit*.yml
```
При том переменную db_host я дергал ручками, что навевало безрадостные мысли о мелких недоделках и доколе(!).
Итого остается делать три вещи: 
  * натравить ansible.cfg на jinventory.json (сам файл динамического инвентори формировать в json-i.sh) 
  * скормить результат вывода terraform output (а конкретно адрес субд) в конфиг app.yml

### app.yml и db_host variable
Раз уж мы дергаем json-i.sh после каждого дестроя ии апплая, пусть потрудится и содержимое outputs в нужном нам ключе пишет в файл с переменными:
```
	dbhost=$(cd ../terraform/stage && terraform output -json db_addr | jq '. []')
	sed -i "s/^db_host:\ .*$/db_host: $dbhost/" variables.yml 
	sed -i 's/"//g' variables.yml
```
Импортируем переменную для variables.yml в задачу:
```
  tasks:
    - include_vars: variables.yml
```
Немного траблшутинга(ну уж и немного): деплой приложений в site.yml должен быть до их конфигурации. Да, я люблю грабли.

Проверка:
```
 terraform destroy
 terraform apply
 2066  ./json-i.sh --list > jinventory.json 
 2067  ansible-playbook site.yml
 2070  curl http://34.77.176.136:9292/ >>>>> <!DOCTYPE html> ...
```

# Ansible-2 packer
Выделим плейлисты, разворачивающие приложения в отдельные файлы для использования в packer
packer_app.yml (конечная версия):
---
```
---
- name: Configure appserver
  hosts: all                                                        # Так как прогоняться будет только создаваемый экземпляр
  become: true
  tasks:
  - name: Install ruby bundler build-essential
    apt:
      name: "{{ packages }}"
    vars:
      packages:
      - ruby-full
      - ruby-bundler
      - build-essential                                            # Если честно, не помню зачем ставил, но кажется нужны.
  - name: Fetch the latest version of application code
    git:
      repo: 'https://github.com/express42/reddit.git'
      dest: /home/appuser/reddit
      version: monolith 
  - name: Bundle install
    bundler:
      state: present
      chdir: /home/appuser/reddit 
  - name: Add unit file for Puma
    copy:
      src: files/puma.service
      dest: /etc/systemd/system/puma.service
    notify: reload puma
  - name: Add config for DB connection
    template:
      src: packer-db_config.j2
      dest: /home/appuser/db_config
  - name: enable puma
    become: true
    systemd: name=puma enabled=yes
  handlers:
  - name: reload puma
    become: true
    systemd: name=puma state=restarted
    ```
```
packer_app.yml (конечная версия):
---
```
---
- name: Configure db server
  hosts: all
  become: true
  vars:
    mongo_bind_ip: 0.0.0.0           # вообще это надо бы оставить ансиблу, но тут ведь совсем чуть-чуть!
  tasks:
  - name: add MongoDB public GPG key
    apt_key: url=https://docs.mongodb.org/10gen-gpg-key.asc id=7F0CEB10 state=present validate_certs=False
  - name: add MongoDB stable repository (for Ubuntu)
    apt_repository: repo='deb http://repo.mongodb.org/apt/{{ ansible_distribution|lower }}  {{ ansible_distribution_release|lower }}/mongodb-org/4.2 multiverse' state=present
    when: ansible_distribution == "Ubuntu"
  - name: run the equivalent of "apt-get update" as a separate step
    apt: 
      update_cache: yes
  - name: install mongo db
    apt: 
      name: mongodb-org
      state: present
      force: yes
  - name: Change mongo config file  # вообще это надо бы оставить ансиблу, но тут ведь совсем чуть-чуть!
    template:
      src: mongod.conf.j2
      dest: /etc/mongod.conf
      mode: 0644
    notify: restart mongod
  handlers:
  - name: restart mongod
    service: name=mongod state=restarted
```
Заменим провижинеры в packer\app.json packer\db.json:
```
    "provisioners": [
        {
            "type": "ansible",
            "playbook_file": "ansible/packer_{app|db}.yml"
        }
    ]
```
Удалим существующий образ и накатим его пару десятков раз заново:
```
$ gcloud compute images list --filter="name=( 'reddit-app-base' )"
```
reddit-app-base  infra-253310  reddit-base              READY
```
$ gcloud compute images delete reddit-app-base
&&
$ packer build -var-file packer/variables.app.json packer/app.json 
```
Повторим процедуру с db образом:

```fatal: [default]: FAILED! => {"changed": false, "msg": "Could not find the requested service mongod: host"}```
Правильно, потому что надо еще mongo залить. Вот этот господин предоставляет неплохой вариант для развертывания:
https://github.com/William-Yeh/ansible-mongodb/blob/master/tasks/use-apt.yml
```
  - name: add MongoDB public GPG key
    apt_key: url=https://docs.mongodb.org/10gen-gpg-key.asc id=7F0CEB10 state=present validate_certs=False
  - name: add MongoDB stable repository (for Ubuntu)
    apt_repository: repo='deb http://repo.mongodb.org/apt/{{ ansible_distribution|lower }}  {{ ansible_distribution_release|lower }}/mongodb-org/4.2 multiverse' state=present
    when: ansible_distribution == "Ubuntu"
  - name: run the equivalent of "apt-get update" as a separate step
    apt: 
      update_cache: yes
  - name: install mongo db
    apt: 
      name: mongodb-org
      state: present
      force: yes
```
Первые десятки блинов, как водится - комом. Листинг сделанных ошибок:
  *использование нотации k:\n v и k=v одновременно, в пределах одной задачи должно быть что то одно
  *путь к шаблонам: указывание templates/template.conf.j2 не работает, а template.conf.j2 - как ни странно, да

## A2 Резолюция. Выводы
По факту проделанной работы выполнен сброс и развертывание инфраструктуры с новоиспеченными образами дисков. Выводы прошедших суток:
  * Документирование (конспектирование) проделанной работы облегчает последующую эксплуатацию.
  * Процесс выпекания образов и откатки плейлистов длительный настолько, что любая автоматизация экономит времени больше, чем занимает ее реализация.
  * Предварительная постановка задачи (записывание ее) не дает отклониться от намеченного курса и должна проводиться вне зависимости от кажущейся простоты разработки.

Самостоятельная работа завершена, работоспособность кода проверена.

<<<<<<< HEAD
# Ansible-3
Роли и окружения в ansible
## Ansible-galaxy

Создание роли:
ansible-galaxy init <role> - создание шаблона роли (соответствующих файлов и папок)
```
$ ansible-galaxy init app
$ ansible-galaxy init db
```

Ознакомимся с шалоном роли:
```
$ tree roles/db
roles/db
├── defaults               # <-- Директория для переменных по умолчанию
│   └── main.yml
├── files                  # <-- Файлы для деплоя. В тасках указывается только basename
├── handlers
│   └── main.yml
├── meta                   # <-- Информация о роли, создателе и зависимостях
│   └── main.yml
├── README.md
├── tasks                  # <-- Директория для тасков
│   └── main.yml
├── templates              # <-- шаблонизированные конфиги. Поиск по умолчанию, в тасках указывается только basename
│   └── mongod.conf.j2
├── tests
│   ├── inventory
│   └── test.yml
└── vars                   # <-- Директория для переменных, которые не должны переопределяться пользователем
    └── main.yml
```

Выполним перенос:
  * списка задач в roles/db/main.yml, 
  * хэндлеров в roles/db/handlers/main.yml
  * используемые переменные в roles/db/defaults/main.yml

Аналогичные действия выполним для роли app
```
$ tree roles/app
roles/app
├── defaults
│   └── main.yml        # <-- db_host: 127.0.0.1
├── files
│   └── puma.service
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── README.md
├── tasks
│   └── main.yml
├── templates
│   └── db_config.j2    # <-- DATABASE_URL= {{ db_host }}  
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml
```

Удалим определение тасков и хендлеров app.yml и db.yml и заменим на вызов роли:

```
---
- name: Configure App
  hosts: app|db  
  become: true  

  roles:    
    - app|db
```

Развернем terraform инфраструктуру (stage-окружение) и проверим работу роли:
```
$ ansible-playbook site.yml --check
$ ansible-playbook site.yml
```
Проверим работу приложения.

<<<<<<< HEAD
## Ansible окружения
=======
##Ansible окружения
>>>>>>> a8b3c2549b4b04ab3c3a11b7a96099bab895e038
  * Создадим директорию environments в директории ansible для определения настроек окружения.
  * В директории ansible/environments создадим две директории для наших окружений stage и prod .
  * Скопируем инвентори файл ansible/inventory в каждую из директорий окружения environtents/prod и environments/stage
  * Исходный inventory удалим
Теперь необходимо указывать используемый inventory при вызове: 
```$ ansible-playbook -i environments/prod/inventory.yml deploy.yml```
Чтобы не делать это каждый раз, можно присвоить значение по умолчанию: 
```
$cat ansible.cfg
inventory = ./environments/stage/inventory.yml # <-- inventory по умолчанию
...
```
<<<<<<< HEAD
### Переменные групп хостов
=======
###Переменные групп хостов
>>>>>>> a8b3c2549b4b04ab3c3a11b7a96099bab895e038
Создадим директорию group_vars в директориях окружений environments/prod и environments/stage.
Перенесем данные из старого плейбука app.yml
```
$ cat environments/stage/group_vars/app 
db_host: 10.132.0.54
...
```

Аналогичные действия для db:
```
$ cat environments/stage/group_vars/db 
mongo_bind_ip: 0.0.0.0
```
Группа all создается по умолчанию для всех хостов. Определим переменные и для нее:
```
$ cat environments/stage/group_vars/all
env: stage
```

Укажем значение env для групп по умолчанию (app|db):
```
$ cat roles/app/defaults/main.yml 
...
env: local
```

Добавим в задачи для ролей вывод информации об окружении:
```
$ cat roles/app/tasks/main.yml 
...
- name: Show info about the env this host belongs to  
  debug:    
    msg: "This host is in {{ env }} environment!!!"
```

Перенесем плейбуки в созданную папку playbooks, прочие (неиспользуемые) файлы от предыдущих занятий в папку old
В корневой папке (ansible) останется только ansible.cfg и requirements.txt

Модифицируем файл настроек:
```
$ cat ansible.cfg 
[defaults]
inventory = ./environments/stage/inventory.yml
remote_user = appuser
private_key_file = ~/.ssh/appuser
host_key_checking = False
retry_files_enabled = False
roles_path = ./roles
vault_password_file = ~/.ansible/vault.key

[diff]
<<<<<<< HEAD
#Включим обязательный вывод diff при наличии изменений и вывод 5 строк контекста
=======
# Включим обязательный вывод diff при наличии изменений и вывод 5 строк контекста
>>>>>>> a8b3c2549b4b04ab3c3a11b7a96099bab895e038
always = True
context = 5
```

Выполним ansible-playbook playbooks/site.yml и убедимся, что окружение развернулось правильно.

Проделаем аналогичные настройки для prod окужения, пересоздадим инфраструктуру и запустим плейбук для окружения prod:
```ansible-playbook -i environments/prod/inventory playbooks/site.yml```

Проверим, что окружение развернулось правильно.


<<<<<<< HEAD
## Работа с Community-ролями
=======
##Работа с Community-ролями
>>>>>>> a8b3c2549b4b04ab3c3a11b7a96099bab895e038

  * Создадим файлы environments/stage/requirements.yml и environments/prod/requirements.yml
```
$ cat environments/stage/requirements.yml 
- src: jdauphant.nginx
  version: v2.21.1
```
  * Установим роль jdauphant.nginx: 
```ansible-galaxy install -r environments/stage/requirements.yml```

  * Добавим jdauphant.nginx в .gitignore
  * Настроим community роль jdauphant.nginx 
```
$ cat environments/stage/group_vars/app
db_host: 10.132.0.54
nginx_sites:
  default:
  - listen 80
  - server_name "reddit"
  - location / {
    proxy_pass http://127.0.0.1:9292;
    }
```
  * добавим прогон jdauphant.nginx в site.yml и проверим развертывание

<<<<<<< HEAD
## Ansible-Vault
=======
##Ansible Vault
>>>>>>> a8b3c2549b4b04ab3c3a11b7a96099bab895e038
Для безопасной работы с приватными данными (пароли, приватные ключи и т.д.) используется механизм Ansible Vault .
Данные сохраняются в зашифрованных файлах, которые при выполнении плейбука автоматически расшифровываются. Таким образом, приватные данные можно хранить в системе контроля версий.
Для шифрования используется мастер-пароль (aka vault key). Его нужно передавать команде ansible-playbook при запуске, либо указать файл с ключом в ansible.cfg. 
!!! Не хранить в в Git
!!! Использовать для разных окружений разный vault key.

  * Создадим vault key за пределами git (или добавить в gitignore, но я против):
  * Добавим ссылку на него в файл настроек:
```
$ cat ansible.cfg 
...
vault_password_file = ~/.ansible/vault.key

```
  * Добавим плейбук для создания пользователей:
```
$ cat playbooks/users.yml 
---
- name: Create users
  hosts: all
  become: true

  vars_files:
    - "{{ inventory_dir }}/credentials.yml"

  tasks:
    - name: create users
      user:
        name: "{{ item.key }}"
        password: "{{ item.value.password|password_hash('sha512', 65534|random(seed=inventory_hostname)|string) }}"
        groups: "{{ item.value.groups | default(omit) }}"
      with_dict: "{{ credentials.users }}"

```
  * Создадим файл с данными пользователей для каждого окружения:
```
$ cat environments/stage/credentials.yml 
---
credentials:
  users:
    admin:
      password: qwerty123
      groups: sudo
    qauser:
      password: test123
```
  * Зашифруем файлы используя vault.key
```
$ ansible-vault encrypt environments/prod/credentials.yml
$ ansible-vault encrypt environments/stage/credentials.yml
```
  * Убедимся, что значение файлов зашифровано
  * Добавим вызов плейбука в файл site.yml и проверим создание окружения
```
TASK [create users]**
changed: [35.240.64.159] => (item={'value': {u'password': u'qwerty123', u'groups': u'sudo'}, 'key': u'admin'})
changed: [34.76.133.231] => (item={'value': {u'password': u'qwerty123', u'groups': u'sudo'}, 'key': u'admin'})
changed: [35.240.64.159] => (item={'value': {u'password': u'test123'}, 'key': u'qauser'})
changed: [34.76.133.231] => (item={'value': {u'password': u'test123'}, 'key': u'qauser'})
```
  * Для редактирования зашифрованных файлов можно использовать ansible-vault edit или предварительно дешифровать (ansible-vault decrypt)

<<<<<<< HEAD
# Ansible-3 Ж
Динамический инвентори

## Постановка задачи
Имеющися парсер динамического инвентори необходимо модифицировать таким образом, чтобы генерируемый файл inventory помещался в указанное окружение.

## Реализация
=======
#Ansible-3 Ж
Динамический инвентори

##Постановка задачи
Имеющися парсер динамического инвентори необходимо модифицировать таким образом, чтобы генерируемый файл inventory помещался в указанное окружение.

##Реализация
>>>>>>> a8b3c2549b4b04ab3c3a11b7a96099bab895e038
Файл json-i.sh модифицирован:
  * ключ -l активирует выполнение функции getList. Указывать файл выгрузки более не требуется, теперь это environments/env-name/dynamic-inventory.json
  * ключ -e <env-name> указывает необходимое окружение
  * ключ -H активирует выполнение функции getHost (выгружает данные для указанного хоста. Бесполезно, но оставил для истории)
  * адрес db (dbhost) устанавливает значение адреса узла СУБД в environments/env-name/group_vars_/app.

Пример запуска:
```
 $./json-i.sh -l -e stage
 $ansible-playbook -i environments/stage/dynamic-inventory.json playbooks/site.yml
```
Деплой протестирован успешно.

