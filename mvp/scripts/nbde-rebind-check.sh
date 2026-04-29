#!/bin/bash
set -euo pipefail

: "${LUKS_DEVICE:?LUKS_DEVICE is not set. Check /etc/default/nbde}"

# confirm the device still exists and is a LUKS volume
if ! lsblk -no FSTYPE "$LUKS_DEVICE" 2>/dev/null | grep -q "crypto_LUKS"; then
    echo "ERROR: $LUKS_DEVICE is not a LUKS device or does not exist." >&2
    # TODO: trigger re-encrypt on next boot
    exit 1
fi

# Use the variables
if clevis luks regen -d "$LUKS_DEVICE" -s 1; then
    echo "NBDE refreshed for $LUKS_DEVICE"
else
    echo "Failed to refresh $LUKS_DEVICE"
    exit 1
fi