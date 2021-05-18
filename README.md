Infra
=====================

Урок 6 (GCP, Scripts)
=====================

**Цель урока:** 

- [ ] Знакомство и установка Google Cloud SDK 
- [ ] Создание инстанса с помощью командной строки и CLI
- [ ] Установка на инстанс Ruby, Bundler, MongoDB
- [ ] Деплой тестового приложения
- [ ] Запуск тестового приложения 

**Задания:** 

- [ ] Создать скрипт установки Ruby 
- [ ] Создать скрипт установки MongoDB
- [ ] Создать скрипт деплоя тестового приложения 

**Дополнительное задание:** 

- [ ] Создать Startup Script, который включает в себя полную установку приложения и всех зависимостей. Скрипт должен запускаться при создании инстанса

Скрипт установки Ruby: 

     #!/bin/bash 
     sudo apt update
     sudo apt install -y ruby-full ruby-bundler build-essential
     if [ $? -ne 0 ]; then
       echo "Failed to install rube and bundler"
       exit 1
     fi

Скрипт установки MongoDB

     wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add

     sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'

     sudo apt-get update

     sudo apt-get install -y mongodb-org

     sudo systemctl start mongod
     if [ $? -ne 0 ]; then
       echo "Failed to start mongod"
       exit 1
     fi

     sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf


     sudo systemctl enable mongod
     if [ $? -ne 0 ]; then
       echo "Failed to enable mongod"
       exit 1
     fi

Скрипт деплоя приложения: 

     git clone -b monolith https://github.com/express42/reddit.git

     cd reddit
     bundle install
     if [ $? -ne 0 ]; then
       echo "Failed to install with bundle"
       exit 1
     fi

     puma -d 

     ps aux | grep puma

Создание инстанса и деплой приложения:

`gcloud compute instances create --boot-disk-size=10GB --image=ubuntu-1604-xenial-v20210211 --image-project=ubuntu-os-cloud -- machine-type=e2-micro --tags=puma-server --restart-on-failure --zone=europe-west1-b reddit-app --metadata-from-file startup-script=startup_script.sh`

Стартап скрипт: 


    #!/bin/bash 

    #RUBY

     sudo apt update
     sudo apt install -y ruby-full ruby-bundler build-essential
     if [ $? -ne 0 ]; then
       echo "Failed to install rube and bundler"
       exit 1
     fi

     #MONGODB

      wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add

     sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'

     sudo apt-get update

     sudo apt-get install -y mongodb-org

     sudo systemctl start mongod
     if [ $? -ne 0 ]; then
       echo "Failed to start mongod"
       exit 1
     fi

     sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf


     sudo systemctl enable mongod
     if [ $? -ne 0 ]; then
       echo "Failed to enable mongod"
       exit 1
     fi
     
     #DEPLOY

     git clone -b monolith https://github.com/express42/reddit.git

     cd reddit
     bundle install
     if [ $? -ne 0 ]; then
       echo "Failed to install with bundle"
       exit 1
     fi

     puma -d 

     ps aux | grep puma

***

Урок 7 (Packer, Systemd)
=====================

**Цель урока:** 

- [ ] Знакомство и установка Packer
- [ ] Создание шаблонов Packer, знакомство со структурой шаблона. 
- [ ] Создание образа с помощью Packer
- [ ] Деплой тестового приложения на инстансе созданном на основе шаблона Packer'a
- [ ] Запуск тестового приложения 

**Задания:** 

- [ ] Параметризировать выданный шаблон, добавив пользовательские переменные:

   - ID проекта (required)
   - source_image (required) 
   - machine_type 

- [ ] Исследовать другие опции builder в шаблоне: 

   - Описание образа 
   - Размер и тип диска 
   - Название сети 
   - Теги

**Дополнительное задание:** 

- [ ] Создать образ, который можно было бы "запечь" (bake). Нужно, чтобы запускался инстанс из созданного образа и на нем сразу же имеем запущенное приложение. 

**Начальный шаблон Packer'a:**

      {
             "builders": [
               {
                  "type": "googlecompute",
                  "project_id": "steam-strategy-174408",
                  "image_name": "reddit-base-{{timestamp}}",
                  "source_image": "image=ubuntu-1604-xenial-v20210211",
                  "zone": "europe-west1-b",
                  "ssh_username": "appuser",
                  "machine_type": "e2-micro"
      } ],
               "provisioners": [
                {
                  "type": "shell",
                  "script": "scripts/install_ruby.sh"
                },
                {
                  "type": "shell",
                  "script": "scripts/install_mongodb.sh",
                  "execute_command": "sudo {{.Path}}"
       } ]
       }

**Шаблон с пользовательскими переменными:**

     {
             "variables": 
               {
                 "proj_id": null,
                 "source_image": null
               },

             "builders":     [
               {
                 "type":                "googlecompute",
                 "project_id":          "{{user `proj_id`}}",
                 "image_name":          "reddit-base-{{timestamp}}",
                 "source_image":        "{{user `source_image`}}",
                 "image_description":   "packer image",
                 "zone":                "europe-west1-b",
                 "ssh_username":        "appuser",
                 "machine_type":        "{{user `machine_type`}}"
                }
                             ],
             "provisioners": [
                 {
                  "type": "shell",
                  "script": "scripts/install_ruby.sh"
                   },
                   {
                   "type": "shell",
                   "script": "scripts/install_mongodb.sh",
                   "execute_command": "sudo {{.Path}}"
                    }                   ]
        }


**Запуск создания образа с шаблоном такого вида:**

     packer build \                         
     -var 'proj_id=week-3-303113' \
     -var 'source_image=ubuntu-1604-xenial-v20210203' \
     ubuntu16.json


**Исследование других опций в builder:**

     {
             "variables": 
               {
                 "proj_id": null,
                 "source_image": null
               },

        "builders":     [
          {
            "type":                "googlecompute",
            "project_id":          "{{user `proj_id`}}",
            "image_name":          "reddit-base-{{timestamp}}",
            "source_image":        "{{user `source_image`}}",
            "image_description":   "packer image",
            "zone":                "europe-west1-b",
            "disk_size":           "10",
            "disk_type":           "pd-standard",
            "network":             "default",
            "tags":                ["puma-server"],
            "ssh_username":        "appuser",
            "machine_type":        "{{user `machine_type`}}"
          }
                        ],
        "provisioners": [
          {
            "type":                "shell",
            "script":              "scripts/startup_script.sh"
          }
                        ]
      }


Создание bake-шаблона: 

Для этого нужно: 

1. Создать systemd-юнит, который будет стартовать при запуске системы
2. Изменить startup-script.sh дополнив инструкциями для сетапа сервиса 
3. Изменить шаблон пакера добавив в секцию провижионеров новую инструкцию 

Systemd:

     [Unit] 

     Description=autostart_redditapp
     After=network.target

     [Service]

     Type=simple
     ExecStart=/usr/local/bin/puma --dir home/appuser/reddit
     Restart=always

     [Install]
     WantedBy=multi-user.target

startup-script.sh:

     wget -P /tmp https://raw.githubusercontent.com/arseny96/infra/base-on-packer/packer/files/autostart_redditapp.service
     sudo mv /tmp/autostart_redditapp.service /etc/systemd/system
     sudo systemctl daemon-reload
     sudo systemctl start autostart_redditapp.service
     sudo systemctl restart autostart_redditapp.service
     sudo systemctl enable autostart_redditapp



 "provisioners": [
         
          {
            "type":                "shell",
            "script":              "scripts/startup_script.sh",
            "execute_command":     "sudo {{.Path}}"
          },
          
          {
           "type":                 "file",
           "source":               "files/autostart_redditapp.service",
           "destination":          "tmp/autostart_redditapp.service"
          }

            
***

Урок 8 (Terraform, Load Balancer, Работа с ресурсами)
=====================

**Цель урока:** 

- [ ] Знакомство и установка Terraform.
- [ ] Создание конфигураций Terraform, разбор их структуры. 
- [ ] Поднятие инстанса с помощью конфигураций terraform на основе собранного ранее образа (с помощью packer). 
- [ ] Деплой тестового приложения. 
- [ ] Научиться работать с переменными. 
- [ ] Научиться писать конфигурацию балансировщика нагрузки и проверить его на работоспособность. 


**Задания:** 

- [ ] Написать конфигурационный файл:

   - Провайдер 
   - Основной ресурс инстанса
   - Ресур метаданных для возможности подключения к инстансу по ssh
   - Написание дополнительного файла outputs.tf, для вывода внешнего Ip-адреса инстанса 
   - Определение правил firewall, для возможности работы тестового приложения 

- [ ] Работа с провижионерами: 

   - Дополнение основого файла конфигурации. 

- [ ] Работа с переменными:

   - Ввод переменных: project, region, public_key_path, disk_image
   - Определение переменных и создание файла terraform.tfvars 

- [ ] Дополнительные задания: 

   - Описать в коде терраформа добавление ssh-ключей нескольких пользователей в метаданные проекта.
   - Создать HTTP-балансировщик, цель которого направлять трафик на развертнутое тестовое приложение. Добавить в output.tf адрес балансировщика. 
   - Добавить параметр ресурса "count" для увеличение кол-ва поднимающихся инстансов. 

**Написание конфигурационного файла**

Обязательное указание провайдера: 

    provider "google" {
      project = virtual-nimbus-******
      region  = europe-west1
      zone    = europe-west1-b
    }

Ресурс "google_compute_instance" для создания инстанса виртуальной машины в GCP:

    resource "google_compute_instance" "app" {
      name         = "test-app"
      machine_type = "e1-micro"
      zone         = "europe-west1-b"
      tag          = ["puma-server"]  #далее созданные правила фаерволла будут применимы только к инстансам с этим тегом
      
    boot_disk {             # определение загрузочного диска 
        initialize_params {
          image = "reddit-base-1621099255"
     } 
    }
    network_interface {     # определение сетевого интерфейса
        network = "default" # сеть, к которой присоединить данный интерфейс 
        access_config {}.   # использовать ephemeral IP для доступа из Интернет 
     } 
    }
    
    connection {   #определение правил подключение провижинеров, которые будут описаны далее
        type = "ssh"
        user = "appuser"
        agent = false
        private_key = "${file("~/.ssh/appuser")}" # путь до приватного ключа
    }

Создание метадаты, для возможности подключения по SSH. Для этого необходимо добавить "metadata" в код описания ресурса "google_compute_instance". 

    metadata {
        ssh-keys = "appuser:${file("~/.ssh/appuser.pub")}"   # путь до публичного ключа
    }

Мне хотелось бы видеть внешний Ip-адрес моего инстанса, для этого необходимо создать отдельный файл output.tf и прописать там: 

    output "external_ip" {
      value = "${google_compute_instance.app.network_interface.0.access_config.0.assigned_nat_ip}"
      
При исполнении, можно будет увидеть следующую строчку: 

    Outputs:
    external_ip = 104.155.68.69
    
Теперь, чтобы тест-апп работал, необходимо определить правило фаервола. В файле main.tf, основном файле конфигурации, я добавлю ресурс "google_compute_firewall":

    resource "google_compute_firewall" "firewall_puma" { 
    name = "allow-puma-default"  # Название сети, в которой действует правило 
    network = "default"
    allow {                      # Какой доступ разрешить 
      protocol = "tcp"
      ports = ["9292"]
    }
    source_ranges = ["0.0.0.0/0"]    # Каким адресам разрешаем доступ 
      target_tags = ["puma-server"]  # Правило применимо для инстансов с перечисленными тэгами
    }

Добавление в конфигурацию провижинеров:

    provisioner "file" {          # Файл с помощью которого можно управлять unit-файлами, проще говоря, в данном случае - сервером тестового приложения 
      source = "files/puma.service"
      destination = "/tmp/puma.service"
    }
    
    provisioner "remote-exec" {   # Скрипт деплоя приложения 
      script = "files/deploy.sh"
    }
    
Итого, файл main.tf должен выглядеть таким образом: 

    resource "google_compute_instance" "app" {
       name = "test-app"
       machine_type = "g1-small"
       zone = "europe-west1-b"
       boot_disk {
         initialize_params {
           image = "reddit-base"
         }
    } 
    metadata {
         ssh-keys = "appuser:${file("~/.ssh/appuser.pub")}"
       }
       tags = ["puma-server"]
         network_interface {
         network = "default"
         access_config {}
       }
       connection {
         type = "ssh"
         user = "appuser"
         agent = false
         private_key = "${file("~/.ssh/appuser")}"
    }

    provisioner "file" {
        source = "files/puma.service"
        destination = "/tmp/puma.service"
    }
    provisioner "remote-exec" {
        script = "files/deploy.sh"
    }
    
    resource "google_compute_firewall" "firewall_puma" { 
        name = "allow-puma-default" 
        network = "default"
        allow {                    
          protocol = "tcp"
          ports = ["9292"]
        }
        source_ranges = ["0.0.0.0/0"]   
          target_tags = ["puma-server"]  
        }    

**Ввод переменных**

Указываю 6 переменных (project, region, zone, image, public_key_path, private_key_path). Синтаксис переменной: "var.variable", где var - обозначение переменной, а variable - имя переменной. 

project, region, zone: 

    provider "google" {
      project = var.project
      region  = var.region
      zone    = var.zone
    }
    
image:

    boot_disk {
        initialize_params {
          image = var.disk_image
        }
      }

public_key_path:

    metadata = {
	    ssh-keys = "appuser:${file(var.public_key_path)}"
      }  
      
 private_key_path:
 
     connection {
             type = "ssh"
             user = "appuser"
             agent = false
             private_key = file(var.private_key_path)
        }
      
Необходимо определить переменные, используя специальный файл "terraform.tfvar": 

    project          = "virtual-nimbus-313719"
    public_key_path  = "~/.ssh/appuser.pub"
    disk_image       = "reddit-base-1621099255"
    
    
Добавлю еще одну переменную: private_key_path    

    private_key_path = "~/.ssh/appuser"
    
Добавление нескольких пользователей в метадату проекта:

maint.tf:

    resource "google_compute_project_metadata_item" "metadata" {
	    key = "ssh-keys"
	    value = join("\n", var.ssh_keys) # join - функция, позволяющая делать список, с разделителем, которые указывается в начале. В этом случае разделитель "\n", другими словами, "с новой строки".
    }
    
terraform.tfvars (ключи - фикция): 

    ssh_keys         = ["appuser1:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzXgPKF/+9S+8dSNo1JHDgWYzmiZCsPpbqa9cOTno8ZQOyi0ET33sHEXxKLtacjIp0jT0mM836Qv60mux+fRNAEYCco2/bQ59NB56+ShqvpiTknd+CtuSuamcPPg0Pf2fsGG7dtxPg1tq8V2EBW81ndUyk5ckyy1evVNcOj3wgUBYv+2x7FDg9Juj/t75CDbR1cH1C1pABffYF/h9HE/o/DtKnK73A2VwH3Vnp3SR5omSNpsFW/V59TzFZqZEbyhfJYusLE3e/5gnS9yAuTM7NbwYeBX26rlIp2BYoBVPFGWJZYzqbT5/Aon+lqhW8Q0DjtNKe3DGoY8cLlZPFOrzZ appuser1", "appuser2:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzXgPKF/+9S+8dSNo1JHDgWYzmiZCsPpbqa9cOTno8ZQOyi0ET33sHEXxKLtacjIp0jT0mM836Qv60mux+fRNAEYCco2/bQ59NB56+ShqvpiTknd+CtuSuamcPPg0Pf2fsGG7dtxPg1tq8V2EBW81ndUyk5ckyy1evVNcOj3wgUBYv+2x7FDg9Juj/t75CDbR1cH1C1pABffYF/h9HE/o/DtKnK73A2VwH3Vnp3SR5omSNpsFW/V59TzFZqZEbyhfJYusLE3e/5gnS9yAuTM7NbwYeBX26rlIp2BYoBVPFGWJZYzqbT5/Aon+lqhW8Q0DjtNKe3DGoY8cLlZPFOrzZ appuser2"]
    
Создать HTTP-балансировщик: 

Необходимо создать файл lb.tf, в нем: 

    resource "google_compute_forwarding_rule" "default" {            # правила описания в какой пул пересылваются пакеты
      name       = "test-app-lb-forwarding-rule"                     # имя правила
      target     = "${google_compute_target_pool.default.self_link}" # ссылка на пул
      port_range = 9292                                              # обязательное указание порта 
    }

    resource "google_compute_target_pool" "default" {     # создание пула вм для балансировщика           
      name = "test-app-lb-target-pool"                    # имя пула

      instances = [                                                 # указание какие именно инстансы должны быть в пуле
        for item in google_compute_instance.app : item.self_link    # далее я буду создавать несколько виртуальный машин с помощью параметра "count", поэтому, чтобы не возвращаться сразу указываю, что все вм в ресурсе google_compute_instance.app - должны находиться в пуле
      ]

      health_checks = [
         "${google_compute_http_health_check.test-app.name}",
      ]
    }

    resource "google_compute_http_health_check" "test-app" {  # ресур для проверки работоспособности машин 
      name               = "test-app-http-health-check"       # имя ресурса
      port               = "9292"                             # в моем случае порт - 9292
      request_path       = "/"                                
      check_interval_sec = 1                                  # как часто проводиться проверка 
      timeout_sec        = 1                                  # ожидание перед объявлением ошибки, дефолтное значение - 5 сек. Я захотел, чтобы это происходило быстрее
    }
    
Еще, хотелось бы установить несколько вм, чтобы написание балансировщика не было бессмысленным. Поэтому, добавляю в код main.tf:

    count        = var.instance_count
    
И в terraform.tfvar: 

    instance_count   = 2
    
А еще необходимо дополнить файл outputs.tf: 

1) Вывод внешних адресов каждой из вм: 

       output "app_external_ip" {
          value = [for item in google_compute_instance.app : item.network_interface[0].access_config[0].nat_ip]

       }
       
2) Вывод адреса балансировщика: 

       output "lb_external_ip" {
          value = google_compute_forwarding_rule.default.ip_address
       }      
       
       
