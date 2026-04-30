#!/bin/bash
set -e

TARGET_DEV="/dev/nvme0n1p3"
TANG_URL="http://192.168.10.6:7500"
IFACE=$(ip link show | grep "^[0-9]: en" | head -1 | awk '{print $2}' | sed 's/:$//')
IP_ADDR="192.168.10.2"
NETMASK="255.255.255.0"
GATEWAY="192.168.10.1"

if [ -z "${IFACE// }" ]; then
    echo "No network interface found. Exiting."
    exit 1
fi

apt-get update && apt-get install -y cryptsetup clevis clevis-luks clevis-tpm2 clevis-initramfs tpm2-tools

cp ./clevis-network.sh /etc/initramfs-tools/hooks/clevis-network
chmod +x /etc/initramfs-tools/hooks/clevis-network

mkdir -p /etc/initramfs-tools/conf.d/
echo "IP=${IP_ADDR}::${GATEWAY}:${NETMASK}::${IFACE}:off" > /etc/initramfs-tools/conf.d/static_ip

read -p "clevis binding [Y,N]" clevis_binding

if [ "$clevis_binding" = "Y" ]; then
    SSS_CONFIG="{\"t\": 2, \"pins\": {\"tpm2\": {\"pcr_ids\": \"7\"}, \"tang\": [{\"url\": \"$TANG_URL\"}]}}"
    clevis luks bind -d "$TARGET_DEV" sss "$SSS_CONFIG"
fi

update-initramfs -u -k all
