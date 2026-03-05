#!/bin/bash

set -e

# automatically re-run with sudo if not root
if [[ $EUID -ne 0 ]]; then
    echo "Re-executing with sudo to gain root privileges..."
    exec sudo bash "$0" "$@"
fi

echo "Downloading latest Minecraft Launcher deb..."
wget -O minecraft-launcher.deb https://launcher.mojang.com/download/linux/x86_64/minecraft-launcher.deb

# Ensure equivs is available for creating dummy packages
echo "Checking for equivs..."
if ! command -v equivs-control >/dev/null 2>&1; then
    echo "equivs not found, installing..."
    apt update && apt install -y equivs
fi

echo "Creating dummy libpixbuf package with equivs..."
equivs-control libpixbuf-dummy
# Modify the control file for a minimal dummy package
cat > libpixbuf-dummy <<EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: libgdk-pixbuf2.0-0
Version: 22.46.6
Architecture: amd64
Depends: libgdk-pixbuf-2.0-0                                         
Provides: libgdk-pixbuf-2.0-0
Description: Dummy package for libpixbuf compatibility
EOF

equivs-build libpixbuf-dummy
dpkg -i libpixbuf-dummy_1.0_all.deb

# Ensure Java runtime is installed
echo "Installing OpenJDK 21 JRE..."
apt update && apt install -y openjdk-21-jre

echo "Installing Minecraft Launcher..."
dpkg -i minecraft-launcher.deb

echo "Fixing broken dependencies..."
apt install --fix-broken -y

echo "Cleanup..."
rm -f minecraft-launcher.deb libpixbuf-dummy*

echo "Minecraft Launcher installed successfully!"