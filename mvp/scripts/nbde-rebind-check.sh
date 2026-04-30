#!/bin/bash
set -euo pipefail

: "${LUKS_DEVICE:?LUKS_DEVICE is not set. Check /etc/default/nbde}"

# confirm the device still exists and is a LUKS volume
if ! lsblk -no FSTYPE "$LUKS_DEVICE" 2>/dev/null | grep -q "crypto_LUKS"; then
    echo "WARN: $LUKS_DEVICE is not a LUKS device or does not exist." >&2
    # TODO: trigger re-encrypt on next boot
    exit 1
fi

MAX_RETRIES=3
RETRY_DELAY=10

for i in $(seq 1 $MAX_RETRIES); do
    if clevis luks regen -d "$LUKS_DEVICE" -s 1 -q; then
        echo "NBDE binding refreshed for $LUKS_DEVICE"
        exit 0
    fi
    echo "Attempt $i/$MAX_RETRIES failed. Retrying in ${RETRY_DELAY}s…"
    sleep $RETRY_DELAY
done

echo "WARN: Could not reach Tang server after $MAX_RETRIES attempts. Giving up."
exit 1