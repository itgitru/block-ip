#!/bin/bash
cd /etc/ufw
rm before.rules
wget https://raw.githubusercontent.com/itgitru/ufw-block-ip/main/before.rules
sleep 2
service ufw restart
