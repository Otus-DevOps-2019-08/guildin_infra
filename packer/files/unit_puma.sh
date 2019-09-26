#!/bin/bash
cat << EOF > /etc/systemd/system/puma.service
[Unit]
Description=Puma D

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/puma -d
StandardOutput=syslog

[Install]
WantedBy=multi-user.target
EOF
service puma start

