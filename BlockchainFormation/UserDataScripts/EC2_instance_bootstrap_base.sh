#!/bin/bash -xe
exec > >(tee /var/log/user_data.log|logger -t user-data -s 2>/dev/console) 2>&1
  # Settings -> enable tracing for commands
  set -x

  # for monitoring of upload and download speed
  # sudo apt install -y ipconfig
  sudo apt install -y ifstat

  # hosts file fix for localhost naming issue with sudo commands on ubuntu 18
  #127.0.0.1 localhost ip-10-6-57-68
  export hsname=$(cat /etc/hostname)
  bash -c 'echo 127.0.0.1 localhost $hsname >> /etc/hosts'

  HTTP_PROXY=http://proxy.ccc.eu-central-1.aws.cloud.bmw:8080
  HTTPS_PROXY=http://proxy.ccc.eu-central-1.aws.cloud.bmw:8080
  NO_PROXY=localhost,127.0.0.1,.muc,.aws.cloud.bmw,.azure.cloud.bmw,.bmw.corp,.bmwgroup.net

  export http_proxy=$HTTP_PROXY
  export https_proxy=$HTTPS_PROXY
  export no_proxy=$NO_PROXY

  bash -c "echo http_proxy=$HTTP_PROXY >> /etc/environment"
  bash -c "echo https_proxy=$HTTPS_PROXY >> /etc/environment"
  bash -c "echo no_proxy=$NO_PROXY >> /etc/environment"

  touch /etc/profile.d/environment_mods.sh
  bash -c "echo http_proxy=$HTTP_PROXY >> /etc/profile.d/environment_mods.sh"
  bash -c "echo https_proxy=$HTTPS_PROXY >> /etc/profile.d/environment_mods.sh"
  bash -c "echo no_proxy=$NO_PROXY >> /etc/profile.d/environment_mods.sh"

  #test if sleeping works for the proxy problem
  sleep 5s

  #this is for going through some of the promts for linux packages
  export DEBIAN_FRONTEND=noninteractive
  DEBIAN_FRONTEND=noninteractive apt-get update || apt-get update && apt-get upgrade -y || apt-get upgrade -y
  apt-get dist-upgrade -y || apt-get dist-upgrade -y
  #apt-get install nginx -y

  #Automatic Security Updates
  apt install unattended-upgrades

  # for monitoring of upload and download speed
  apt install -y ifstat
  # for monitoring i/o
  apt-get install sysstat -y

  echo "APT::Periodic::Update-Package-Lists "1";
  APT::Periodic::Download-Upgradeable-Packages "1";
  APT::Periodic::AutocleanInterval "7";
  APT::Periodic::Unattended-Upgrade "1";" >> /etc/apt/apt.conf.d/20auto-upgrades

  #THIS ONLY WORKS IF THE UNMOUNTED DISK IS THE BIGGEST DISK ON VM
  UNMOUNTED=`lsblk --noheadings --raw -o NAME,MOUNTPOINT,SIZE | sort -u -h -k 2 | awk '{print $4 " " $1}'  | tail -n 1`
  #remove whitespace
  UNMOUNTED=`(echo -e "${UNMOUNTED}" | tr -d '[:space:]')`
  echo $UNMOUNTED
  #mounting disk
  mkdir /data
  mkfs -t ext4 /dev/$UNMOUNTED
  mount /dev/$UNMOUNTED /data
  DISKUUID=`sudo file -s /dev/$UNMOUNTED | awk '{print $8}'`
  bash -c  "echo '$DISKUUID       /data   ext4    defaults,nofail        0       2' >> /etc/fstab"

  bash -c  "sudo chown -R ubuntu:ubuntu /data"

  # switch to normal user
  cat << EOF | su ubuntu
  cd ~

  #echo "Initial Script finished, Starting more advanced installs now"

  #add users with bash shell



