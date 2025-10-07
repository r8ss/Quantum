#!/bin/bash

# Linux setup.
sudo apt update && \
DEBIAN_FRONTEND=noninteractive sudo apt install -yq \
  attr ccache clang ffmpeg golang \
  libbrotli-dev libgtest-dev libprotobuf-dev libunwind-dev libpcre2-dev \
  libzstd-dev linux-modules-extra-$(uname -r) lld protobuf-compiler webp \
  p7zip-full lz4 android-sdk-libsparse-utils wget python3 python3-pip && \
sudo modprobe erofs f2fs

# Installing Python packages. (silent)
pip3 install liblp google-api-python-client google-auth-httplib2 google-auth-oauthlib tgcrypto pyrogram
pip3 install git+https://github.com/martinetd/samloader.git

# Cleanup.
sudo apt clean
rm -rf ~/.cache/*
sudo apt autoclean
sudo apt autoremove -y
