#!/bin/bash -xe

  # Getting updates (and upgrades)
  sudo apt-get update
  sudo apt-get -y upgrade || echo "Upgrading in indy_bootstrap failed" >> /home/ubuntu/upgrade_fail2.log


  sudo apt install -y openjdk-8-jre-headless

  (cd /data && git clone https://github.com/corda)


  # =======  Create success indicator at end of this script ==========
  sudo touch /var/log/user_data_success.log

EOF