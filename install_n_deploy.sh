#!/bin/bash
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential

#mongodb install
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.2.list'
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

#deploy
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
