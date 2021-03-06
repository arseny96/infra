#!/bin/bash

wget -O - https://raw.githubusercontent.com/arseny96/infra/base-on-packer/scripts/install_ruby.sh | sudo bash
if [ $? -ne 0 ]; then
  echo "Failed to install ruby"
  exit 1
fi




wget -O -  https://raw.githubusercontent.com/arseny96/infra/base-on-packer/scripts/install_mongodb.sh | sudo bash
if [ $? -ne 0 ]; then
  echo "Failed to install mongo"
  exit 1
fi




cd /home/appuser

wget -O -  https://raw.githubusercontent.com/arseny96/infra/base-on-packer/scripts/deploy.sh | sudo bash
if [ $? -ne 0 ]; then
  echo "Failed to deploy reddit"
  exit 1
fi



wget -P /tmp https://raw.githubusercontent.com/arseny96/infra/base-on-packer/packer/files/autostart_redditapp.service
sudo mv /tmp/autostart_redditapp.service /etc/systemd/system
sudo systemctl daemon-reload
systemctl start autostart_redditapp.service
sudo systemctl restart autostart_redditapp.service
systemctl enable autostart_redditapp
