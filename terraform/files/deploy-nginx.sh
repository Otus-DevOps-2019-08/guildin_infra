#!/bin/bash
if [[ `ps aux | grep apt | wc -l` -gt 1 ]]; then echo "WAITING 15 sec" && sleep 15s; else echo "apt SEEMS 2B OK"; fi
sudo apt install --yes nginx
sudo mv /tmp/lb.conf /etc/nginx/conf.d/
sudo unlink /etc/nginx/sites-enabled/default
sudo service nginx restart
