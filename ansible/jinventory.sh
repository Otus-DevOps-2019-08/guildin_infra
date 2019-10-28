#!/bin/bash

function getHost () {
	if [[ -n $1 ]]
	then
		printf "getting data for host $1  \n"
		cat inventory.json | jq '._meta.hostvars['\"$1\"']' > jinventory.json
	else
		printf "No hostname specified!"
	fi
	}

function getList() {
	cat inventory.json | jq '. | {hosts: .ungrouped.hosts}' > jinventory.json
	printf "Here is our inventory\n\n"
	}

#Грузим джейсона простыней от GCP
ansible-inventory -i inventory.gcp.yml --output inventory.json
#(реально страшная простыня)

echo
while [ -n "$1" ]
do
	case "$1" in
		--list) getList ;;
		--host) getHost $2 ;;
		--help) printf "usage: jinventory.sh ARGS\n --list - перечень хостов в инвентори \n --host [hostname] - выдать json-данные по этому хосту.\n";;
#		*) echo "Это так не работает. Не могу распознать $1. почитайте --help" ;;
	esac
	shift
done

