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
	HostName 34.76.12.102
	User atikhonov.gcp
	IdentityFile ~/.ssh/gcp_id_rsa
Host someinternalhost
	HostName 10.132.0.3
	User atikhonov.gcp
	ProxyJump bastion

