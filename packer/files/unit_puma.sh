#!/bin/bash
cat << EOF > ~/puma.service
[Unit]
Description=Puma HTTP Forking Server
After=network.target

[Service]
# Background process configuration (use with --daemon in ExecStart)
Type=forking

# Preferably configure a non-privileged user
# User=

# The path to the puma application root
# Also replace the "<WD>" place holders below with this path.
WorkingDirectory=/home/atikhonov.gcp/reddit

# The command to start Puma
# (replace "<WD>" below)
ExecStart=bundle exec puma --daemon --dir /home/atikhonov.gcp/reddit

# The command to stop Puma
# (replace "<WD>" below)
ExecStop=bundle exec pumactl -S /tmp/puma.state stop

# Path to PID file so that systemd knows which is the master process
PIDFile=/tmp/puma.pid

# Should systemd restart puma?
# Use "no" (the default) to ensure no interference when using
# stop/start/restart via `pumactl`.  The "on-failure" setting might
# work better for this purpose, but you must test it.
# Use "always" if only `systemctl` is used for start/stop/restart, and
# reconsider if you actually need the forking config.
Restart=no

# `puma_ctl restart` wouldn't work without this. It's because `pumactl`
# changes PID on restart and systemd stops the service afterwards
# because of the PID change. This option prevents stopping after PID
# change.
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
chmod +x ~/puma.service
sudo ln ~/puma.service /etc/systemd/system
sudo service puma start

