#!/bin/bash

##########################################################################
if [ -z "$script_dir" ]
then
    echo "do not run this script directly !"
    echo "this script is part of ipxe-install-pxe-server-pass2.sh"
    exit -1
fi
##########################################################################


######################################################################
######################################################################
## variables, you have to customize
## e.g.:
##  RPI_SN0 : serial number
##            of the raspberry pi 3 for network booting
##  and other variables...
######################################################################
######################################################################
CUSTOM_LANG=en
CUSTOM_LANG_LONG=en_US
CUSTOM_LANG_UPPER=US
CUSTOM_LANG_WRITTEN=English
CUSTOM_LANG_EXT=en-latin1-nodeadkeys
CUSTOM_TIMEZONE=America/New_York
######################################################################
COUNTRY_WLAN0=$CUSTOM_LANG_UPPER
######################################################################
RPI_SN0=--------
RPI_SN0_BOOT=rpi-$RPI_SN0-boot
RPI_SN0_ROOT=rpi-$RPI_SN0-root
######################################################################
INTERFACE_ETH0=
INTERFACE_BR0=br0
##########################################################################
if [ -z "$INTERFACE_ETH0" ] && [ -d /sys/devices/platform/scb/fd580000.genet/net ]; then
# RPi4B
INTERFACE_ETH0=$(ls /sys/devices/platform/scb/fd580000.genet/net)
fi
if [ -z "$INTERFACE_ETH0" ] && [ -d /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/1-1.1.1/1-1.1.1:1.0/net ]; then
# RPi3B+
INTERFACE_ETH0=$(ls /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/1-1.1.1/1-1.1.1:1.0/net)
fi
if [ -z "$INTERFACE_ETH0" ] && [ -d /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/1-1.1:1.0/net ]; then
# RPi1B rev.1, RPi1B rev.2, RPi1B+, RPi2B, RPi3B
INTERFACE_ETH0=$(ls /sys/devices/platform/soc/*.usb/usb1/1-1/1-1.1/1-1.1:1.0/net)
fi
if [ -z "$INTERFACE_ETH0" ]; then
# fallback
INTERFACE_ETH0=eth0
fi
######################################################################
IP_ETH0=$(ip -4 address show dev $INTERFACE_ETH0 | grep -o -E '(([0-9]{1,3}[\.]){3}[0-9]{1,3})' | sed '1!d')
IP_ETH0_=$(echo $IP_ETH0 | grep -E -o "([0-9]{1,3}[\.]){3}")
IP_ETH0_0=$(echo $(echo $IP_ETH0_)0)
IP_ETH0_START=$(echo $(echo $IP_ETH0_)200)
IP_ETH0_END=$(echo $(echo $IP_ETH0_)250)
IP_ETH0_ROUTER=$(echo $(ip rout show dev $INTERFACE_ETH0 | grep default | cut -d' ' -f3))
IP_ETH0_DNS=$IP_ETH0_ROUTER
IP_ETH0_MASK=255.255.255.0
IP_BR0=192.168.1.1
IP_BR0_START=192.168.1.200
IP_BR0_END=192.168.1.250
IP_BR0_MASK=255.255.255.0
######################################################################
ISO=/iso
IMG=/img
TFTP_ETH0=/tftp
NFS_ETH0=/nfs
SRC_MOUNT=/media/server
SRC_BACKUP=$SRC_MOUNT/backup
SRC_ISO=$SRC_BACKUP$ISO
SRC_IMG=$SRC_BACKUP$IMG
SRC_TFTP_ETH0=$SRC_BACKUP$TFTP_ETH0
SRC_NFS_ETH0=$SRC_BACKUP$NFS_ETH0
DST_ROOT=/media/server
DST_ISO=$DST_ROOT$ISO
DST_IMG=$DST_ROOT$IMG
DST_TFTP_ETH0=$DST_ROOT$TFTP_ETH0
DST_NFS_ETH0=$DST_ROOT$NFS_ETH0
######################################################################
#DST_PXE_BIOS=menu-bios
#DST_PXE_EFI32=menu-efi32
#DST_PXE_EFI64=menu-efi64
##__Set variable below if you'll be using ipxe instead 
##__(you may comment out the 3 DST_PXE above)
DST_IPXE=ipxe
#############
OS_VER=$(grep VERSION_ID /etc/*-release |  grep -o '".*"' | sed 's/"//g')
