#!/bin/bash
#
# Install VLMCSD (KMS server emulator in C) service script for Debian based systems
# by DniGamer
# based on: https://teevee.asia/others/setup-your-own-kms-server-on-centos/
#
# 2022
#

# CHECKS FOR RESULTS IN FUNCTIONS TO SHOW ERROR MESSAGES
check_result() {
  if [ $1 -ne 0 ]; then
    echo "Error: $2" >&2
    exit $1
  fi
}

# CHECKS IF SCRIPT IS BEING RUN AS ROOT
if [ "x$(id -u)" != 'x0' ]; then
  echo 'Error: This script can only be executed by root.'
  exit 1
fi

# CHECKS IF SERVICE/vlmcsd IS ALREADY INSTALLED
if [ -f '/etc/init.d/vlmcsd' ]; then
  echo 'VLMCSD service had already been installed on this system.'
  exit 1
fi

# UPDATES REPOSITORIES FOR PACKAGE INSTALLATION
apt update -y

# INSTALL TAR
if [ ! -f '/bin/tar' ]; then
  echo 'Installing tar...'
  apt install tar -y
  check_result $? "Couldn't install tar."
  echo 'Installed tar successfully.'
fi

# INSTALL WGET
if [ ! -f '/usr/bin/wget' ]; then
  echo 'Installing wget ...'
  apt install wget -y
  check_result $? "Couldn't install wget."
  echo 'Installed wget successfully.'
fi

# MAKE TEMP DIR
TMP_DIR=`mktemp -d`

# CHECK IF FILES EXIST AND IF DON'T, DOWNLOAD THEM
if [ -f "binaries/vlmcsd.tar.gz" ]; then
  echo "vlmcsd.tar.gz exists."
  cp binaries/vlmcsd.tar.gz $TMP_DIR
else 
  echo "vlmcsd.tar.gz does not exist. Downloading ..."
  wget -q https://github.com/dnigamer/vlmcsd-linux/binaries/vlmcsd.tar.gz -O vlmcsd.tar.gz
  check_result $? 'Download vlmcsd binary failed.'
  cp vlmcsd.tar.gz $TMP_DIR
fi

if [ -f "scripts/vlmcsd-debian" ]; then
  echo "vlmcsd-debian exists."
  cp scripts/vlmcsd-debian $TMP_DIR
else 
  echo "vlmcsd-debian does not exist. Downloading ..."
  wget -q https://github.com/dnigamer/vlmcsd-linux/scripts/vlmcsd-debian -O vlmcsd-debian
  check_result $? 'Download startup script failed.'
  cp vlmcsd-debian $TMP_DIR
fi

# CHANGE DIRECTORY TO TEMP FOLDER
cd $TMP_DIR

# EXTRACT BINARIES
echo 'Extracting vlmcsd...'
tar zxf vlmcsd.tar.gz
cp binaries/Linux/intel/static/vlmcsd-x86-musl-static /usr/bin/vlmcsd
cp vlmcsd-debian /etc/init.d/vlmcsd

# FIX FILE PERMISSIONS
echo 'Fixing file permissions...'
chmod 755 /usr/bin/vlmcsd
chown root.root /usr/bin/vlmcsd
chmod 755 /etc/init.d/vlmcsd
chown root.root /etc/init.d/vlmcsd
check_result $? 'Error while configuring file permissions.'

# ADD SERVICE TO SYSTEMCTL
echo 'Configuring vlmcsd service...'
systemctl daemon-reload
systemctl enable --now vlmcsd
systemctl start vlmcsd
check_result $? 'Error while configuring systemctl service.'

# CLEANING TEMP FOLDER
echo 'Cleaning temporary folder...'
rm -rf ${TMP_DIR}

echo 'vlmcsd installed successfully! Running on port 0.0.0.0:1688.'