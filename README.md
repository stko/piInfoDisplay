# piInfoDisplay
## Introduction

piInfoDisplay is designed as a kind of traffic light at the entrance of a shop, where in Corona times only a limited number of persons are allowed to be inside.

![display](https://raw.githubusercontent.com/stko/piInfoDisplay/master/display.png)

piInfoDisplay allows to define two different texts (one with green and one with red backfround color) through its simple web interface. 


![web](https://raw.githubusercontent.com/stko/piInfoDisplay/master/web.png)


It also opens its own AccessPoint (Hotspot), so everybody from the Shop personal can change the display from his mobile, tablet or laptop. Of course a wired network connection is also supported. 

With that own hotspot there is no need to have another internet connection around.


## Install

To install piInfoDisplay, 
- create a raspian lite image from raspberry.org (tested on raspian jessie)
- boot your raspberry from that image, 
- login
- start the install script with

    bash <(curl -s https://raw.githubusercontent.com/stko/piInfoDisplay/master/install.sh)

the installation will take appr. 30 minutes.

After the installation you should adjust your settings before reboot, because after that your file system will be read only (which you can temporarily change with `sudo mount -o remount,rw /` then)

After reboot, your Raspi will boot with a read only filesystem, opens a hotspot and shows the InfoDisplay- Window ready to receive commands
