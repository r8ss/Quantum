#!/bin/bash


install_packages() {
    echo ""
    echo "Detecting Operating system"
    OS=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    echo "Operating system: $OS"

    # Debian / Ubuntu
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        echo "Installing for Ubuntu/Debian..."
        apt update && apt install -y p7zip-full unzip tar lz4 openjdk-17-jdk e2fsprogs perl git xxd android-sdk-libsparse-utils file cpio util-linux gawk

    # Arch Linux
    elif [ "$OS" = "arch" ]; then
        echo "Installing for Arch Linux..."
        pacman -Syu --noconfirm --needed p7zip unzip tar lz4 jdk-openjdk e2fsprogs perl git xxd android-tools file cpio util-linux gawk

    # Fedora
    elif [ "$OS" = "fedora" ]; then
        echo "Installing for Fedora..."
        sudo dnf -y upgrade && sudo dnf -y install p7zip p7zip-plugins unzip tar lz4 java-21-openjdk-devel e2fsprogs perl git vim-common android-tools file cpio util-linux gawk
    else
        echo "Unsupported OS: $OS"
        return 1
    fi

    echo "Installation complete"
}