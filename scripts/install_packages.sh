#!/bin/bash

# Linux setup.
sudo apt update -y
sudo apt install -y p7zip-full lz4 android-sdk-libsparse-utils wget util-linux python3 python3-pip

# Installing Python packages.
pip3 install liblp google-api-python-client google-auth-httplib2 google-auth-oauthlib tgcrypto pyrogram
pip3 install git+https://github.com/martinetd/samloader.git

# Cleanup.
sudo apt clean
rm -rf ~/.cache/*
sudo apt autoclean
sudo apt autoremove -y
