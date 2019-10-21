#!/bin/bash
sudo env=$(cat /tmp/grab.env)
sudo sed '/\[Service\]/a $env' /etc/systemd/system/puma.service
sudo service puma restart