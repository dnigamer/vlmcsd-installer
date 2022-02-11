#!/bin/bash
#
# Uninstall VLMCSD service script for Debian based systems
# by DniGamer
#
# 2022
#

# STOP RUNNING SERVICE
systemctl stop vlmcsd

# DELETE init.d SERVICE FILE
rm /etc/init.d/vlmcsd

# RELOAD systemctl
systemctl daemon-reload

# REMOVE vlmcsd BINARY
rm /usr/bin/vlmcsd
