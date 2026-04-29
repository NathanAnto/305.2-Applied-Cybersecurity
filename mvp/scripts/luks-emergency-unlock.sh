#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)"
  exit 1
fi

read -p "Enter the LUKS device path (e.g., /dev/nvme0n1p3): " DEVICE
read -p "Enter a name for the mapped device (e.g., crypt_recovery): " MAP_NAME
read -p "Enter the threshold number of shares (t): " THRESHOLD_T

echo "[*] Starting Shamir's Secret Sharing reconstruction..."
echo "[*] You will be prompted to enter $THRESHOLD_T shares below."

# We capture the output of ssss-combine. 
# ssss-combine is interactive, so we run it normally.
RECONSTRUCTED_SECRET=$(ssss-combine -t "$THRESHOLD_T" -q 2>&1)

# Check if we got a valid-looking secret (ssss-split -q outputs just the result)
if [ -z "$RECONSTRUCTED_SECRET" ]; then
    echo "[-] Reconstruction failed or was empty."
    exit 1
fi

echo "[*] Attempting to unlock $DEVICE as /dev/mapper/$MAP_NAME..."

# Try to unlock using the reconstructed secret
echo "$RECONSTRUCTED_SECRET" | cryptsetup open "$DEVICE" "$MAP_NAME" --key-file -

if [ $? -eq 0 ]; then
    echo "[+] Success! The drive is now unlocked at /dev/mapper/$MAP_NAME"
    echo "[*] You can now mount it: mount /dev/mapper/$MAP_NAME /mnt"
else
    echo "[-] Failed to unlock. The reconstructed key might be incorrect."
    exit 1
fi

# Clear the secret from memory
unset RECONSTRUCTED_SECRET