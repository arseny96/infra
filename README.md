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

            
