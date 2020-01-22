#!/bin/bash -xe

  # Getting updates (and upgrades)
  sudo apt-get update
  sudo apt-get -y upgrade || echo "Upgrading in indy_bootstrap failed" >> /home/ubuntu/upgrade_fail2.log

   # Getting curl
  sudo apt install curl

  # Installing docker
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  # Testing the installation
  docker --version
  sudo docker run hello-world

  # Installing docker-compose
  sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  # Testing the installation
  docker-compose --version

  # Eventually user permissions need to be adjusted... rebooting required!
  sudo usermod -aG docker ubuntu
  newgrp docker
  # Testing whether docker runs without user permissions
  docker run hello-world

  # Setting up go (TODO: check whether go is necessary)
  # echo 'Y' | sudo apt-get install golang-go
  wget -c https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz
  sudo tar -xvzf go1.12.7.linux-amd64.tar.gz -C /usr/local
  rm go1.12.7.linux-amd64.tar.gz


  # Get CouchDB image
  docker pull apache/couchdb:latest


  # =======  Create success indicator at end of this script ==========
  sudo touch /var/log/user_data_success.log

EOF