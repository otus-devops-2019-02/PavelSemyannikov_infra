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
        },

Проверка
packer validate -var-file=variables.json config.json

Сборка
packer build -var-file=variables.json config.json

Инофрмация о шаблоне
packer inspect config.json


