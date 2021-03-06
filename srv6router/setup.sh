#!/bin/bash

##############################################################################################
# Copyright (C) 2018 Pier Luigi Ventre - (CNIT and University of Rome "Tor Vergata")
# Copyright (C) 2018 Stefano Salsano - (CNIT and University of Rome "Tor Vergata")
# www.uniroma2.it/netgroup - www.cnit.it
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# The script installs SRv6Router node packages on Linux Ubuntu 17.10
#
# @author Pier Luigi Ventre <pierventre@hotmail.com>
# @author Stefano Salsano <stefano.salsano@uniroma2.it> 

echo -e "\n"
echo "############################################################"
echo "##                 SRv6 Router node setup                 ##"
echo "##                                                        ##"
echo "##    The installation process can last many minutes.     ##"
echo "##   Plase wait and do not interrupt the setup process.   ##"
echo "############################################################"

install_quagga(){
  apt install -y gawk
  apt install -y texinfo
  apt install -y quagga

  #create folders and set permissions
  mkdir -p /var/log/quagga
  chown quagga:quagga /var/log/quagga

  mkdir -p /var/run/quagga
  chown quagga:quagga /var/run/quagga

  # Set proper permissions to the quagga folder
  #chown quagga:quaggavty /etc/quagga/*.conf
  chown quagga:quaggavty /etc/quagga/*.conf
  chmod 640 /etc/quagga/*.conf

  
}

install_iproute2(){
  wget https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.15.0.tar.gz
  tar -zxvf iproute2-4.15.0.tar.gz
  cd iproute2-4.15.0
  make
  make install
  cd ../
  rm -r iproute2-4.15.0
  rm iproute2-4.15.0.tar.gz
}

# Make sure only root can run our script
echo -e "\nChecking permission"
if [ "$(id -u)" != "0" ]; then
   echo -e "This script must be run as root\n" 1>&2
   exit 1
fi
echo -e "Ok!"

# Verify the setup has not been already performed
echo -e "\nChecking setup already performed"
if [ -f /etc/setup ]; then
  echo -e "Setup already executed...exit\n"
  exit 0
fi
echo -e "Ok!"

# Trasform in a magic number and compare against 410
echo -e "\nChecking Kernel version"
if [ $(uname -r | awk -F. '{print $1$2}') -lt 410 ]; then
  echo -e "SRv6 not supported in this kernel...exit\n"
  exit 0
fi
echo -e "Ok!"

echo -e "\nInstalling dependencies"
# Let's install all the dependencies
apt update

echo -e "\nInstalling OpenVPN"
# We need openvpn for tunnels
apt-get install -y openvpn

echo -e "\nInstalling VLAN packages"
# Vlan can be always useful
apt install -y vlan

echo -e "\nInstalling make"
apt install -y make

echo -e "\nInstalling pkg-Config"
apt install -y pkg-config

echo -e "\nInstalling bison"
apt install -y bison

echo -e "\nInstalling flex"
apt install -y flex

echo -e "\nInstalling Quagga router services"
# Quagga dependencies are: gawk, textinfo
install_quagga

echo -e "\nInstalling iproute2"
install_iproute2

echo -e "\nInstalling traceroute"
apt install traceroute

echo -e "Ok!"

# Create setup file
touch /etc/setup

echo -e "\nSRv6 Router node setup ended succesfully. Enjoy!\n"


EXIT_SUCCESS=0
exit $EXIT_SUCCESS
