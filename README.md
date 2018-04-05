# Gatekeeper: Long Range RFID Stealing and Cloning  
Gatekeeper is the next step in the evolution of long range RFID thieving. This project builds on several previous projects while adding new features and expanding the possibilities. 
  
Before going any further, I want to make sure to acknowledge those who helped this project, without knowing they did so. 
1. Mike Kelly for the Wiegotcha code (https://github.com/lixmk/Wiegotcha). 
2. Fran Brown and BishopFox for the original Tastic RFID Thief (https://www.bishopfox.com/resources/tools/rfid-hacking/attack-tools/). Much of the original Arduino code was ported over into gatekeeper.c.  
3. pidoorman RPi wiegand reader code (http://pidoorman.co.uk/).  
4. Kyle Mallory for his fork of the above pidoorman code (found at https://gist.github.com/hsiboy/9598741).  
5. Derek Eder for his csv to html code (https://github.com/derekeder/csv-to-html-table).  
6. Gordon Henterson for the wiringPi library (https://projects.drogon.net/raspberry-pi/wiringpi/).  
  
## Information  
Gatekeeper is a tool designed for physical penetration testers in order to capture and clone RFID tags from unsuspecting targets. Similar to it's predecessor, the Tastic RFID Thief and the Wiegotcha project, the Gatekeeper is designed to be placed inside an HID Maxiprox 5375 (125kHz ProxII cards), Indala ASR-620 (Indala), or an HID R90 (13.56mHz iClass cards). A raspberry pi is used in combination with a proxmark3 board in order to steal RFID information and immediately clone it to a card. The pi creates a WIFI access point which can be connected to in order to access the web UI.
  
Default Passwords:  
* root:Gatekeeper  
* pi:Gatekeeper  
  
IP Addressing:  
* eth0 = DHCP  
* wlan0 = 192.168.150.1  
  
Access Point:  
* ESSID: Gatekeeper  
* Pass: Gatekeeper  
  
**Do not forget to change default passwords!**

## Code Installation
### Easy Mode  
Easy mode installation is the same as installing any OS on your raspberry pi.  
1. Download the image from: https://drive.google.com/file/d/1gRQ0itS_2Zorfb1CtqN_J-AB9BlKPw_-/view?usp=sharing
2. Check .gz sha256 sum: 5bf4432fc03052329c97f73ef2ded0a3bd908484a4ac3087b216b9a2abe2b2e3
3. Decompress the image.
4. Check .img sha256 sum: 9116c6bac390977548415f12c72d258f3aef79e27c9cd9e0bd2017ad973d8d50
5. Use dd (or Win32 Disk Imager on windows) to push the image to your sd card.
6. Ensure ethernet cable is connected and boot.
7. Run `/root/Gatekeeper/fixclock.sh` to set correct time to hardware clock.  
8. Proceed to Hardware Installation.  
  
### Manual (longer) Mode
"Manual" installation is still fairly straight forward. Feel free to explore install.sh and laststep.sh to fully understand what they do.  
1. Burn a fresh Raspbian stretch lite SD card. You can use Jessie or Jessie-lite but this hasn't been fully tested.  
2. Run `sudo su -` to become root  
3. Run `apt-get update && apt-get -y install git`  
4. In /root run `git clone https://github.com/wghozayel/Gatekeeper`  
5. Run `cd Gatekeeper && ./install.sh`  
6. The install script will walk you through everything, including a reboot.  
7. After first reboot run `screen -dr install` (as root)  
8. Follow instructions to complete final steps of installation.  
9. Proceed to Hardware Installation.  
  
## Hardware Installation
![Wiring Diagram](https://drive.google.com/file/d/1yu8LFOeut5fmFZEjpC6wAvRoutqETLB7/view?usp=sharing)
1. Connect the RTC GND pin to the RPi pin 9.
2. Connect the RTC VCC pin to RPi pin 1.
3. Connect the RTC SDA pin to RPi pin 3.
4. Connect the RTC SCL pin to RPi pin 5.
5. Run RPi pin 4 to Level Shifter HV in.  
6. Run RPi pin 6 to Level Shifter LV GND.  
7. Run RPi pin 11 to Level Shifter LV 1.  
8. Run Rpi pin 12 to Level Shifter LV 4.  
9. Run RPi pin 17 to Level Shifter LV in.  
10. Reader TB1-3 to Battery Ground (Black).  
11. Reader TB1-1 to Battery 12v (Red).  
12. Reader TB2-1 to Level Shifter HV 1  
13. Reader TB2-2 to Level Shifter HV 4  
14. Reader TB1-2 to Level Shifter HV gnd.  
OPTIONAL: Remove Speaker.  
OPTIONAL: Solder haptic motor.  

## BOM
* Raspberry Pi 3: https://www.amazon.com/dp/B01CD5VC92/  
* RFID Reader (Maxiprox 5375, Indala ASR-620, iClass R90): https://www.amazon.com/dp/B002I15F90/ (Maxiprox 5375. Check eBay for better prices)  
* Proxmark3 kit: https://www.amazon.com/dp/B072KNWWN3/
* Level Shifter: https://www.amazon.com/dp/B00RT03GSC/, https://www.sparkfun.com/products/12009 (Many option exist, some may come presoldered for the extra lazy)  
* DS3231 Real-time Clock: https://www.amazon.com/dp/B01IXXACD0/  
* Micro SD Card (8GB or larger): https://www.amazon.com/dp/B017NT8PNE/ (Just an example)  
* 12v Battery with 5v USB: https://www.amazon.com/dp/B00ME3ZH7C/  
* Jumper wires (I use 5 Female to Female and 3 Male to Female): https://www.amazon.com/dp/B01EV70C78/  
* Short USB Mirco Cable: https://www.amazon.com/dp/B00VXH697W/  
* Haptic Motor (Optional) : https://www.adafruit.com/products/1201  
