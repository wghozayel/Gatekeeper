# Gatekeeper: Long Range RFID Stealing and Cloning  
Gatekeeper is the next step in the evolution of long range RFID thieving. This project builds on several previous projects while adding new features and expanding the possibilities. 
  
Before going any further, I want to make sure to acknowledge those who helped this project, without knowing they did so. 
1. Mike Kelly for the Wiegotcha code. 
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
