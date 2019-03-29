# PavelSemyannikov_infra
PavelSemyannikov Infra repository

===========
Homework #3
===========

# Подключение к someinternalhost через bastion в одну строку
 ssh -At user_bastion@ip_baction ssh user_someinternalhost@ip_someinternalhost

# Пример: 
 ssh -At pavel@104.199.7.33 ssh pavel@10.132.0.5

# Подключение к someinternalhost через bastion по ssh-алиасу
# 1. Добавить в  ~/./ssh/config:
	Host someinternalhost
		HostName ip_someinternalhost
		User user_someinternalhost
		ProxyCommand ssh -W %h:%p user_bastion@ip_baction

# Пример: 
	Host someinternalhost
		HostName 10.132.0.5
	        User pavel
        	ProxyCommand ssh -W %h:%p pavel@104.199.7.33

# 2. Теперь можно подключаться по алиасу "someinternalhost"
 ssh someinternalhost

