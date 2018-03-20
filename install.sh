#!/bin/bash
########################################################################
########################################################################
######################                            ######################
######################  Gatekeeper Install Script ######################
######################                            ######################
########################################################################
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################
########################################################################
#
#
echo -e "\e[0;31m#############################################################\e[0m"
echo -e "\e[0;31m#\e[0m                                                           \e[0;31m#\e[0m"
echo -e "\e[0;31m#\e[0m     This script script will install and configure all     \e[0;31m#\e[0m"
echo -e "\e[0;31m#\e[0m     necessary dependancies and services for Gatekeeper     \e[0;31m#\e[0m"
echo -e "\e[0;31m#\e[0m                                                           \e[0;31m#\e[0m"
echo -e "\e[0;31m#\e[0m       This script is not completely automated some        \e[0;31m#\e[0m"
echo -e "\e[0;31m#\e[0m     interaction is required. Watch for prompts in red     \e[0;31m#\e[0m"
echo -e "\e[0;31m#\e[0m                                                           \e[0;31m#\e[0m"
echo -e "\e[0;31m#\e[0m         Additionally Gatekeeper is intended to be          \e[0;31m#\e[0m"
echo -e "\e[0;31m#\e[0m       installed on a fresh, dedicated raspberry pi        \e[0;31m#\e[0m"
echo -e "\e[0;31m#\e[0m                                                           \e[0;31m#\e[0m"
echo -e "\e[0;31m#\e[0m    CTRL-C now to quit now or press ENTER to continue.     \e[0;31m#\e[0m"
echo -e "\e[0;31m#\e[0m                                                           \e[0;31m#\e[0m"
echo -e "\e[0;31m#############################################################\e[0m"
read -e NULL

echo "[*] Starting installation."

#Checking if root. Will sudo
USER="$(whoami)"
if [ "$USER" != "root" ]
then
  echo "[!] Not running as root."
  echo -e "\e[0;31m[*] Switching to root. Enter root password.\e[0m"
  sudo su -
else
  echo "[*] cd'ing into /root/."
  cd ~
fi

#Changing root pw if approved
echo -e "\e[0;31m[+] Do you want to change the root password?\e[0m"
echo -n "[+] 'yes' or 'no': "
read -e RESP1
if [ "$RESP1" = "yes" ]
then
  echo -e "\e[0;31m[+] Set root password.\e[0m"
  passwd
  echo "[*] root password set."
else
  echo "[*] Not changing root password."
fi

#Checking to allow root ssh login
echo -e "\e[0;31m[+] Do you want to allow root via ssh?\e[0m"
echo "[+] Doing so may present a security risk, especially if defaults are left."
echo "[+] but will allow for greater ease of use in the field."
echo -n "[+] 'yes' or 'no': "
read -e RESP2
if [ "$RESP2" = "yes" ]
then
  echo "[*] Modding sshd_config to allow root ssh login."
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
  sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
else
  echo "[*] Root SSH login not permitted."
fi
#Changing pi password
echo -e "\e[0;31m[+] Do you want to change the pi user password?\e[0m"
echo -n "[+] 'yes' or 'no': "
read -e RESP3
if [ "$RESP3" = "yes" ]
then
  echo -e "\e[0;31m[+] Set pi password.\e[0m"
  passwd pi
  echo "[*] pi password set."
else
  echo "[!] Ensure pi password is no longer default before field use."
fi

#Proceding with installation
echo "[*] Proceeding with installation."
echo "[*] Updating raspbian. This could take a while..."
apt-get update
apt-get -y dist-upgrade
apt-get -y install hostapd isc-dhcp-server screen
apt-get --force-yes -y install expect p7zip build-essential libreadline5 libreadline-dev libusb-0.1-4 libusb-dev libqt4-dev perl pkg-config libncurses5-dev gcc-arm-none-eabi libstdc++-arm-none-eabi-newlib supervisor
echo "[*] Updating complete."

#Changing hostname for purely vain reasons
echo "[*] Setting Gatekeeper hostname"
sed -i 's/raspberrypi/Gatekeeper/g' /etc/hosts
echo 'Gatekeeper' > /etc/hostname

#Insatlling WiringPi
echo "[*] Installing WiringPi."
cd ~/
git clone git://git.drogon.net/wiringPi 
cd wiringPi
./build
cd ~/

#Installing proxmark3
echo "[*] Installing Proxmark3."
git clone https://github.com/proxmark/proxmark3.git
cd proxmark3
git pull
cp -rf driver/77-mm-usb-device-blacklist.rules /etc/udev/rules.d/77-mm-usb-device-blacklist.rules
udevadm control --reload-rules
make clean && make all
mkdir scan
cp ~/Gatekeeper/confs/clone.sh ./scan/
cd ~/


#Copying Gatekeeper specific conf files
#Configs include: dhcpd, hostapd, interfaces, rc.local, and default html pages
#Probably need to mod /etc/modules
echo "[*] Copying config files"
cd ./Gatekeeper/
cp ./confs/dhcpd.conf /etc/dhcp/
cp ./confs/hostapd.conf /etc/hostapd/
cp ./confs/interfaces /etc/network/
mkdir /var/www
mkdir /var/www/html
cp -R ./html/* /var/www/html/
cp ./confs/rctmp.local /etc/rc.local
cp ./laststep.sh ../
cp ./gatekeeper_webserv.py ~/
cp ./confs/gatekeeper_supervisor.conf /etc/supervisor/conf.d/
mkdir /var/www/html/backup/
sed -i 's|#DAEMON_CONF=""|DAEMON_CONF=/etc/hostapd/hostapd.conf|g' /etc/default/hostapd
echo "[*] Compiling Gatekeeper C code"
gcc -o ../gatekeeper gatekeeper.c -L/usr/local/lib -lwiringPi -lpthread

#Enable i2c on boot for hardware clock
#TODO: This is currently done via raspi-config.
#TODO: Hoping to eliminate the interaction.
echo "[+] Enabling i2c on boot."
echo -e "\e[0;31m[+] This step requires the use of raspi-config, which is a manual process\e[0m."
echo -e "\e[0;31m[+] Use Interfacing Options (5), then I2C (P5), yes, then finish.\e[0m"
echo -n -e "\e[0;31m[+] When you're ready, press any key to continue: \e[0m"
read -e NULL
raspi-config
echo -e "\e[0;31m[+] The system will now reboot. After reboot, login then 'sudo su -' (or login as root)\e[0m"
echo -e "\e[0;31m[+] Once you're root, type 'screen -dr install' to complete the installation.\e[0m"
reboot
