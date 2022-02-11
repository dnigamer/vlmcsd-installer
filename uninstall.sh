#!/bin/bash
#
# Uninstall VLMCSD service for Debian based systems
# by DniGamer
#
# 2022
#

systemctl stop vlmcsd
rm /etc/init.d/vlmcsd
rm /usr/bin/vlmcsd
systemctl daemon-reload
