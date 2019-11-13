#!/bin/bash
function getHost () {
echo "Host is $1"
}

function getList() {
echo "List is set"
}

while getopts Hle:h option
do
case "${option}"
in
H) getHost=${OPTARG}; shift ;;
l) getList;;
e) env=${OPTARG}; shift ;;
h) printf "usage: $0 ARGS\n -l parse inventory list \n -H [hostname] - выдать json-данные по этому хосту.\n -e указать environment(stage by default)";;
*) printf "What is your options, dude?\n usage: $0 ARGS\n -l parse inventory list \n -H [hostname] - выдать json-данные по этому хосту.\n -e указать environment(stage by default)"
esac
done

echo "Environment: $env"


