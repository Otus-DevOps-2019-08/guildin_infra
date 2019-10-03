#!/bin/bash
chmod +x /tmp/puma.service
mv /tmp/puma.service /etc/systemd/system
systemctl enable puma
service puma start 

