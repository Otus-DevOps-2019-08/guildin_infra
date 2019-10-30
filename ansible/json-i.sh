#!/bin/bash
function getHost () {
	if [[ -n $1 ]]
	then
		printf "getting data for host $1  \n"
		ansible-inventory -i files/inventory.gcp.yml --list --output inventory.json
		cat inventory.json | jq '._meta.hostvars['\"$1\"']' > inventory.json
	else
		printf "No hostname specified!"
	fi
	}

function getList() {
	ansible-inventory -i files/inventory.gcp.yml --list --output inventory.json
	printf "{\n" 
	printf "    \"all\": {\n"
	printf "         \"children\":{\n"
	
#имплементация группировки хостов. В данной работе предпочту не реализовывать.
#Вместо этого возьму hostname и сделаю вид, что так и было.
#Да, будет ругаться на дефисы. Все равно будет, можно было бы sed 's/-//g'
	cat inventory.json | sed 's/-//' |  jq '._meta' | jq '.hostvars' | jq '.[]' | jq '.name' > fill.arr
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
	
	dbhost=$(cd ../terraform/stage && terraform output -json db_addr | jq '. []')
	sed -i "s/^db_host:\ .*$/db_host: $dbhost/" variables.yaml 
	sed -i 's/"//g' variables.yaml

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



