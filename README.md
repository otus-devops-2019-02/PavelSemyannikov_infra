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
# 1. Добавить в  ~/./ssh/config:
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

