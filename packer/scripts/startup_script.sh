#!/bin/bash

# install ruby and dependencies
wget -O - https://raw.githubusercontent.com/arseny96/infra/base-on-packer/scripts/install_ruby.sh | sudo bash
if [ $? -ne 0 ]; then
  echo "Failed to install ruby"
  exit 1
fi

# install db
wget -O -  https://raw.githubusercontent.com/arseny96/infra/base-on-packer/scripts/install_mongodb.sh | sudo bash
if [ $? -ne 0 ]; then
  echo "Failed to install mongo"
  exit 1
fi

# run app
cd /home/appuser

wget -O -  https://raw.githubusercontent.com/arseny96/infra/base-on-packer/scripts/deploy.sh | sudo bash
if [ $? -ne 0 ]; then
  echo "Failed to deploy reddit"
  exit 1
fi

