#!/bin/bash

# AnyDesk installation script
# Downloads the latest .deb package and installs it

ANYDESK_URL="https://download.anydesk.com/linux/anydesk_7.1.4-1_amd64.deb"
ANYDESK_DEB="anydesk.deb"

echo "Downloading AnyDesk..."
wget "$ANYDESK_URL" -O "$ANYDESK_DEB"

if [ $? -eq 0 ]; then
    echo "Installing AnyDesk..."
    sudo dpkg -i "$ANYDESK_DEB"
    echo "Installation complete."
    rm "$ANYDESK_DEB"
else
    echo "Failed to download AnyDesk."
    exit 1
fi