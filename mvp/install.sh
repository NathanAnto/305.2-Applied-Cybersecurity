#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/config.env"
# source "$SCRIPT_DIR/lib/log.sh"

# Find device that is in LUKS Format
TARGET_DEV="/dev/$(lsblk -lo NAME,FSTYPE | awk '$2 == "crypto_LUKS" {print $1}')"

if [ "${#TARGET_DEV}" -lt 5 ]; then
    echo "No LUKS device found."
    # TODO: run reencrypt on next boot
    exit 1
fi

IFACE=$(ip link show | grep "^[0-9]: en" | head -1 | awk '{print $2}' | sed 's/:$//')

if [ -z "${IFACE// }" ]; then
    echo "No network interface found. Exiting."
    exit 1
fi

IP_ADDR=$(ip -4 addr show $IFACE | awk '/inet / {print $2}' | cut -d/ -f1)
 
# -----------------------------------------------------------------------------
# Install dependencies
# -----------------------------------------------------------------------------
apt-get update && apt-get install -y cryptsetup clevis clevis-luks clevis-tpm2 clevis-initramfs tpm2-tools ssss

cp ./lib/clevis-network.sh /etc/initramfs-tools/hooks/clevis-network
chmod +x /etc/initramfs-tools/hooks/clevis-network

# log_info "Installing NBDE rebind service…"
 
# Write runtime env file — systemd injects LUKS_DEVICE into the script at boot
mkdir -p "$(dirname "$NBDE_ENV_FILE")"
echo "LUKS_DEVICE=${TARGET_DEV}" > "$NBDE_ENV_FILE"
chmod 600 "$NBDE_ENV_FILE"
# log_info "Runtime env written to $NBDE_ENV_FILE"

# Install unit file and the rebind script to their final locations
install -Dm 644 "$SCRIPT_DIR/units/nbde-rebind.service" \
    "${UNIT_INSTALL_DIR}/nbde-rebind.service"
install -Dm 755 "$SCRIPT_DIR/scripts/nbde-rebind-check.sh" \
    "${SCRIPTS_INSTALL_DIR}/nbde-rebind-check.sh"

# log_info "Unit and script installed."

# -----------------------------------------------------------------------------
# Static IP for initramfs (network unlock)
# -----------------------------------------------------------------------------
mkdir -p /etc/initramfs-tools/conf.d/
echo "IP=${IP_ADDR}::${GATEWAY}:${NETMASK}::${IFACE}:off" > /etc/initramfs-tools/conf.d/static_ip

# log_info "Rebuilding initramfs…"

update-initramfs -u -k all

# -----------------------------------------------------------------------------
# Clevis LUKS binding
# -----------------------------------------------------------------------------
read -p "clevis binding [y,N]" clevis_binding

if [ "$clevis_binding" = "y" ]; then
    SSS_CONFIG=$(printf \
        '{"t": 2, "pins": {"tpm2": {"pcr_ids": "1,7"}, "tang": [{"url": "%s"}]}}' \
        "$TANG_SERVER_URL"
    )
    clevis luks bind -d "$TARGET_DEV" sss "$SSS_CONFIG"
fi

systemctl enable --now "$SERVICE_NAME"

# log_info "Installation complete."
