#!/bin/bash

# Run as sudo
# https://www.reddit.com/r/pop_os/comments/uf54bi/how_to_remove_or_disable_brltty/
# To allow some usb serial peripherals. Check errors using 'sudo dmesg'.

systemctl stop brltty-udev.service
sudo systemctl mask brltty-udev.service
systemctl stop brltty.service
systemctl disable brltty.service
