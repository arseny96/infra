#!/bin/bash

wget -O - https://raw.githubusercontent.com/Otus-DevOps-2019-08/whoami-io_infra/cloud-testapp/install_ruby.sh | bash
if [ $? -ne 0 ]; then
  echo "Failed to install ruby"
  exit 1
fi

wget -O - https://raw.githubusercontent.com/Otus-DevOps-2019-08/whoami-io_infra/cloud-testapp/install_mongodb.sh | bash
if [ $? -ne 0 ]; then
  echo "Failed to install mongo"
  exit 1
fi

cd /home/appuser

wget -O - https://raw.githubusercontent.com/arseny96/infra/base-on-packer/scripts/deploy.sh | sudo bash
if [ $? -ne 0 ]; then
  echo "Failed to deploy reddit"
  exit 1
fi






