[![Build Status](https://api.travis-ci.com/otus-devops-2019-02/PavelSemyannikov_infra.svg)](https://api.travis-ci.com/otus-devops-2019-02/PavelSemyannikov_infra)

# PavelSemyannikov_infra
PavelSemyannikov Infra repository

# Homework #3

bastion_IP = 104.199.7.33
someinternalhost_IP = 10.132.0.5

# SSH Howto

# Подключение к someinternalhost через bastion в одну строку
 ssh -At bastion_user@baction_ip ssh someinternalhost_user@someinternalhost_ip

# Пример: 
 ssh -At pavel@104.199.7.33 ssh pavel@10.132.0.5

# Подключение к someinternalhost через bastion по ssh-алиасу
# 1. Добавить в  ~/.ssh/config:
	Host someinternalhost
		HostName someinternalhost_ip
		User someinternalhost_user
		ProxyCommand ssh -W %h:%p bastion_user@baction_ip

# Пример: 
	Host someinternalhost
		HostName 10.132.0.5
	        User pavel
        	ProxyCommand ssh -W %h:%p pavel@104.199.7.33

# 2. Теперь можно подключаться по алиасу "someinternalhost"
 ssh someinternalhost


# Homework #4

testapp_IP = 35.205.92.144
testapp_port = 9292

# Create VM and use startup script
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=/home/pavel/projects/PavelSemyannikov_infra/startup_script.sh

# Create Firewall rule
gcloud compute firewall-rules create default-puma-server\
 --direction=INGRESS \
 --source-ranges=0.0.0.0/0 \
 --allow=tcp:9292 \
 --target-tags=puma-server
 
# Homework #5
 
Пример конфига шаблона gcp для packer. Переменные можно передавать из файла или аргументами (-var-file=path vs -var 'key=value')
 
 
 variables.json
 
	{
        "project_id" : "gcp-project-id",
        "source_image_family" : "ubuntu-1604-lts",
        "machine_type": "f1-micro",
        "image_description" : "packer image otus-devops 2019-02",
        "disk_size" : "10",
        "disk_type" : "pd-standard",
        "network" : "default",
        "tags" : "puma-server"
 	 }
 
 
 config.json
  
  	{
     	"variables": {
        "project_id": null,
        "source_image_family": null,
        "machine_type": "f1-micro",
        "image_description" : "packer image",
        "disk_size" : "10",
        "disk_type" : "pd-standard",
        "network" : "default",
        "tags" : ""
   	 },
	"builders": [
            {
            "type": "googlecompute",
            "project_id": "{{ user `project_id` }}",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-base",
            "source_image_family": "{{ user `source_image_family` }}",
            "zone": "europe-west1-b",
            "ssh_username": "appuser",
            "machine_type": "{{ user `machine_type` }}",
            "image_description": "{{ user `image_description` }}",
            "disk_size": "{{ user `disk_size` }}",
            "disk_type": "{{ user `disk_type` }}",
            "network": "{{ user `network` }}",
            "tags": "{{ user `tags` }}"
            }
         ],
        "provisioners": [
            {
            "type": "shell",
            "script": "somescript.sh",
            "execute_command": "sudo {{.Path}}"
             }
	  ]

Проверка
	packer validate -var-file=variables.json config.json

Сборка
	packer build -var-file=variables.json config.json

Информация о шаблоне
	packer inspect config.json

# Homework #6 Terraform-1

Добавление ssh-ключей проекта на примере нескольких пользователей (appuser, appuser1, appuser2

	resource "google_compute_project_metadata_item" "default" {
	  key   = "ssh-keys"
	  value = "appuser:${file("${var.public_key_path}")}\nappuser1:${file("${var.public_key_path}")}\nappuser2:${file("${var.public_key_path}")}"
	}

При выполнении terraform apply все ключи в проекте заменяются на указанные в terraform, т.е. вручную добавлять нет смысла.

При копировании в лоб однотипных инстансов в terraform конфиг забивается ненужным однотипным мусором. 
Лучше использовать параметр count, а в именах инстансов, например, переменную "count.index"
Пример:

	resource "google_compute_instance" "app" {
	  count        = "3"
	  name         = "reddit-app-${count.index}"


# Homework #7 Terraform-2

Пример файла backend.tf при хранении state в бакете gcloud

	terraform {
	  backend "gcs" {
	    bucket = "storage-bucket-pavel-s-otus-devops-states"
	    prefix = "stage"
	  }
	}

Можно работать с таким стэйтом из любого места, где есть конфиги. При одновременном apply стэйт лочиться пока не отработает у первого запустившего.
Attention! Главное случайно не убить сам бакет, особенно если он создавался средствами terraform

При развертывании stage и prod инфраструктуры можно добавить префикс (данном случае переменная infra_prefix) чтобы они не конфликтовали, эту переменную нужно
добавить во все конфликтующие места в модулях (имена, тэги и т.п.)

При использовании провижинга и модулей пути к файлам используемый провиженером нужно писать относительно папки из которой запускается terraform, 
т.е. не "files/script.sh", а "../modules/app/files/script.sh"

Output-переменные из модулей можно юзать в основных конфигах как "module.module_name.output_var_name"

# Homework #8 Ansible-1

После удаления папки с reddit изменилось значение changes т.к. плейбук выполнил клонирование. 
Ранее changes было равно 0, т.к. приложение уже было и модуль git не выполнял никаких действий на app.

Для динамического инвентори написан скрипт на python с использованием модуля google-api-python-client. 
При вызове скрипта "./inventory.py --list" возвращаеться json со списком хостов по группам app, db и others (в others хосты не попавшие в другие группы). Пустые группы не возвращаются.
В ansible.cfg в качестве inventory прописан это скрипт. 
Файл inventory.json не нужен, но по условиям задачи он должен быть, поэтому сделал его так "./inventory.py --list > inventory.json".
Зависимость google-api-python-client добавлена в requirements.txt

# Homework #9 Ansible-2

Самый полезный линк https://docs.ansible.com/ansible/latest/modules/list_of_all_modules.html

Пример передачи переменной из хоста на все хосты в пределах плэйбука.

    tasks:
      - set_fact: db_host="{{ ansible_default_ipv4.address }}"
        delegate_to: "{{ item }}"
        with_items: "{{ play_hosts }}"
        delegate_facts: True
        when: "'db' in inventory_hostname"

Для dynamic inventory с GCP самый кошерный вариант gce.py, банально потому что по нему куча инфы. 
Как вариант, можно написать самостоятельно, например, как делал в предыдущем ДЗ. Но проще взять gce.py.
С ним неудобно, то что нельзя хосты по группам раскидывать, но можно попробовать группировать по тегам или метаданным.

# Homework #10 Ansible-3

Заметки:
trytravis - мега штука для отладки проверок.
Мои проверки в репе https://github.com/PavelSemyannikov/travis-test.git
gce.py умеет фильтровать хосты по тэгам, но не умеет (надеюсь пока) по label.
ansible-galaxy знает про кучу ролей, но видимо нужно смотреть что внутри роли происходит. 

# Homework #11 Ansible-4

В провижионе пакера можно передавать extra параметры, пример:

	"provisioners": [
        	{
            		"type": "ansible",
            		"ansible_env_vars": [ "ANSIBLE_ROLES_PATH=ansible/roles" ],
            		"extra_arguments": [ "--tags=ruby" ],
            		"playbook_file": "ansible/playbooks/packer_app.yml",
            		"user": "appuser"
        	}
    	]

Molecule в качестве рабочей папки использует /tmp/molecule. Логи и прочее надо искать там.
SSH-ключ который она генерит нужно добавить в ssh-agent если есть ошибки подключения.

На WSL все работает, но Vagrant должен стоять как на винде, так и в wsl (одинаковой версии). Также нужно добавить кстомные опции в конфиг провайдера:
 	
	config.vm.provider :virtualbox do |v|
    		v.memory = 1024
    		v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
  	end
