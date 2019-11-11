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
if [ -d "environments/$env" ]; then
    invFile="environments/$env/dynamic-inventory.json"
	ansible-inventory -i files/inventory.gcp.yml --list --output environments/${env}/inventory.json
	printf "{\n" > ${invFile}
	printf "    \"all\": {\n" >> ${invFile}
	printf "         \"children\":{\n" >> ${invFile}
	
#имплементация группировки хостов. В данной работе предпочту не реализовывать.
#Вместо этого возьму hostname и сделаю вид, что так и было.
#Да, будет ругаться на дефисы. Все равно будет, можно было бы sed 's/-//g'
	cat environments/${env}/inventory.json | sed 's/-//' |  jq '._meta' | jq '.hostvars' | jq '.[]' | jq '.name' | sed 's/reddit//g' > fill.arr
	i=0
	while read line
	do
		HOSTS[$i]="$line"
		i=$(($i+1))
	done < fill.arr
	rm fill.arr
	
	i=0
	cat environments/${env}/inventory.json |  jq '._meta' | jq '.hostvars' | jq '.[]' | jq '.networkInterfaces' | jq '.[0]' | jq '.accessConfigs' | jq '.[0]' | jq '.natIP' > IPs.arr	
	while read line
	do
		IPs[$i]="$line"
		i=$(($i+1))
	done < IPs.arr
	rm IPs.arr
	
	j=0
	for h in "${HOSTS[@]}"
	do
		printf "        ${HOSTS[$j]}: {\n                 \"hosts\": {\n" >> ${invFile}
		printf "${IPs[$j]}: null }\n" >> ${invFile}
	
		if [[ $((i-j)) > 1 ]]; then printf "},\n" >> ${invFile} ; else printf "}\n" >> ${invFile} ; fi 
		j=$(($j+1))
	done	
			printf "             }\n       }\n}\n" >> ${invFile}
	
	dbhost=$(cd ../terraform/stage && terraform output -json db_addr | jq '. []')
	sed -i "s/^db_host:\ .*$/db_host: $dbhost/" environments/${env}/group_vars/app 
	sed -i 's/"//g' environments/${env}/group_vars/app

  else
	printf "No such an environment"
	break
fi


	}

while getopts Hle:h option
do
case "${option}"
in
H) getHost=${OPTARG}; shift ;;
l) listFunction=true;;
e) env=${OPTARG}; shift ;;
h) printf "usage: $0 ARGS\n -l parse inventory list \n -H [hostname] - выдать json-данные по этому хосту.\n -e указать environment(stage by default)";;
*) printf "What is your options, dude?\n usage: $0 ARGS\n -l parse inventory list \n -H [hostname] - выдать json-данные по этому хосту.\n -e указать environment(stage by default)"
esac
done


if [ $listFunction ]; then getList; fi

