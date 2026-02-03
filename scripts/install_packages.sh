#!/bin/bash

# Linux setup.
# sudo apt update
sudo apt install -y p7zip-full lz4 android-sdk-libsparse-utils liblp python3 python3-pip

# Installing Python packages.
pip3 install tgcrypto pyrogram

# Run with sudo to avoid path problem.
pip3 install git+https://github.com/martinetd/samloader.git

# Cleanup.
sudo apt clean
rm -rf ~/.cache/*
sudo apt autoclean
sudo apt autoremove -y
