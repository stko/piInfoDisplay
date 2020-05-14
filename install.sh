
##### To install piInfoDisplay, get a virgin raspian lite image from raspberry.org
# tested on raspian stretch
#  boot the virgin raspian image, login
#  do 'export DEBUG=YES' first, if the finished image shall not become read-only. This is good for debugging, but bad for daily use..
#
# start the install script with
#    bash <(curl -s https://raw.githubusercontent.com/stko/piInfoDisplay/master/install.sh)
# and spent some hours with your friends or family. When you are back,
# the installation should be done

PROGNAME=piInfoDisplay

echo "The $PROGNAME Installer starts"
cd

sudo apt-get update --assume-yes
sudo apt-get install --assume-yes \
joe \
python3-pip \
usbmount \
python3-tk \
tk-dev \
xserver-xorg \
xinit \
x11-xserver-utils \
openbox \
xserver-xorg-video-fbdev 



#sudo pip3 install tkinter

# Read-Only Image instructions thankfully copied from https://kofler.info/raspbian-lite-fuer-den-read-only-betrieb/

# remove packs which do need writable partitions
sudo apt-get remove --purge --assume-yes cron logrotate triggerhappy dphys-swapfile fake-hwclock samba-common
sudo apt-get autoremove --purge --assume-yes

wget  https://github.com/stko/$PROGNAME/archive/master.zip -O $PROGNAME.zip && unzip $PROGNAME.zip
mv $PROGNAME-master $PROGNAME
# uncomment in case of special config files
# sudo mkdir /etc/$PROGNAME
# sudo cp $PROGNAME/scripts/sample_* /etc/$PROGNAME/
# sudo rename 's/sample_//' /etc/$PROGNAME/sample*


chmod a+x /home/pi/$PROGNAME/*.py
chmod a+x /home/pi/$PROGNAME/scripts/*.sh


# start to make the system readonly
sudo rm -rf /var/lib/dhcp/ /var/spool /var/lock /var/lib/misc
sudo ln -s /tmp /var/lib/misc
sudo ln -s /tmp /var/lib/dhcp
sudo ln -s /tmp /var/spool
sudo ln -s /tmp /var/lock
sudo chmod -R a+rwx /tmp
if [ -f /etc/resolv.conf ]; then
	sudo mv /etc/resolv.conf /tmp/resolv.conf
fi
sudo ln -s /tmp/resolv.conf /etc/resolv.conf

# add the temporary directories to the mountlist
cat << 'MOUNT' | sudo tee /etc/fstab
proc            /proc           proc    defaults          0       0
/dev/mmcblk0p1  /boot           vfat    ro,defaults          0       2
/dev/mmcblk0p2  /               ext4    ro,defaults,noload,noatime  0       1
# a swapfile is not a swap partition, no line here
#   use  dphys-swapfile swap[on|off]  for that
tmpfs	/var/log	tmpfs	nodev,nosuid	0	0
tmpfs	/var/tmp	tmpfs	nodev,nosuid	0	0
tmpfs	/tmp	tmpfs	nodev,nosuid	0	0
#/dev/sda1       /media/usb0     vfat    ro,defaults,nofail,x-systemd.device-timeout=1   0       0
MOUNT

#add boot options
echo -n " fastboot noswap" | sudo tee --append /boot/cmdline


# setting up the systemd services
# very helpful source : http://patrakov.blogspot.de/2011/01/writing-systemd-service-files.html

# EOF is NOT quoted ('') to allow variable substitution in the HERE document
cat << EOF | sudo tee  /etc/systemd/system/$PROGNAME.service
[Unit]
Description=$PROGNAME Main Server
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/bin/xinit /home/pi/$PROGNAME/scripts/$PROGNAME.sh 
Restart=on-failure

[Install]
WantedBy=default.target

EOF


sudo systemctl enable $PROGNAME


# create Hot- Spot

sudo rfkill list all
sudo rfkill unblock 0


sudo apt-get install -y -qq --no-install-recommends \
hostapd \
joe \
dnsmasq

cat << 'EOF' | sudo tee --append  /etc/dhcpcd.conf
interface wlan0
static ip_address=192.168.48.1/24
 
EOF
 
cat << 'EOF' | sudo tee  /etc/dnsmasq.conf
# DHCP-Server aktiv für WLAN-Interface
interface=wlan0
 
# DHCP-Server nicht aktiv für bestehendes Netzwerk
no-dhcp-interface=eth0
 
# IPv4-Adressbereich und Lease-Time
dhcp-range=192.168.48.100,192.168.48.200,255.255.255.0,24h
 
# DNS
dhcp-option=option:dns-server,192.168.48.1
EOF


sudo systemctl restart dnsmasq

# DNSMASQ-Status anzeigen:
sudo systemctl status dnsmasq

#DNSMASQ beim Systemstart starten:
sudo systemctl enable dnsmasq

cat << 'EOF' | sudo tee  /etc/hostapd/hostapd.conf
# WLAN-Router-Betrieb
# Schnittstelle und Treiber
interface=wlan0
#driver=nl80211
# WLAN-Konfiguration
ssid=piInfoDisplay
channel=1
hw_mode=g
ieee80211n=1
ieee80211d=1
country_code=DE
wmm_enabled=1
# WLAN-Verschlüsselung
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_passphrase=kindergarten
# needed to allow list of connected devices sudo hostapd_cli list_sta 
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
EOF
 
cat << 'EOF' | sudo tee --append /etc/default/hostapd
RUN_DAEMON=yes
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF


sudo systemctl unmask hostapd
sudo systemctl start hostapd
sudo systemctl enable hostapd



cat << 'EOF'
Installation finished

SSH is enabled and the default password for the 'pi' user has not been changed.
This is a security risk - please login as the 'pi' user and type 'passwd' to set a new password."

Also this is the best chance now if you want to do some own modifications,
as with the next reboot the image will be write protected

if done, end this session with
 
     sudo halt

and your $PROGNAME all-in-one is ready to use

have fun :-)

the $PROGNAME team
EOF

sync
sync
sync
