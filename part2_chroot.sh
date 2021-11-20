#!/bin/bash

echo "Ping before mounting proc/ sys/  dev/pts ..."
ping -c 4 8.8.8.8

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts

echo "----CUSTOMIZATION STARTS----"

echo "Ping after mounting "
sudo apt-get update
sudo apt-get install git vim curl -y

echo "Downloading some application (in this case, a mining program)"

git clone https://github.com/nuriyevn/r12  /r12
git clone https://github.com/nuriyevn/r16  /r16
chmod +x /r12/xmrig
chmod +x /r16/xmrig

echo "Let's change root password:"
passwd root

echo "Setting HUGESPAGES"
sudo ysctl -w vm.nr_hugepages=1500



