#!/bin/bash

# Linux setup.
apt update -y  > /dev/null 2>&1 && apt upgrade -y  > /dev/null 2>&1
apt install -y p7zip-full lz4 android-sdk-libsparse-utils wget python3 python3-pip  > /dev/null 2>&1

# Installing Python packages. (silent)
pip3 install liblp google-api-python-client google-auth-httplib2 google-auth-oauthlib tgcrypto pyrogram  > /dev/null 2>&1
pip3 install git+https://github.com/martinetd/samloader.git  > /dev/null 2>&1

# Cleanup.
sudo apt clean
rm -rf ~/.cache/*
sudo apt autoclean
sudo apt autoremove -y
