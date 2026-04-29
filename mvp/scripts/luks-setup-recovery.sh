#!/bin/bash
# This script should be run by admins who can then split the secrets between them.

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)"
  exit 1
fi

read -p "Enter the LUKS device path (e.g., /dev/nvme0n1p3): " DEVICE
if [ ! -b "$DEVICE" ]; then
  echo "Error: Device $DEVICE not found."
  exit 1
fi

# 1. Generate high-entropy recovery key
echo "[*] Generating a 512-bit recovery key..."
RECOVERY_KEY=$(openssl rand -base64 64)

# 2. Add the key to the LUKS device
# This will prompt the user for an existing password to authorize the new key
echo "[*] Adding the recovery key to a new LUKS slot."
echo "[!] You will be prompted for an EXISTING LUKS passphrase now."
echo "$RECOVERY_KEY" | cryptsetup luksAddKey "$DEVICE" -

if [ $? -eq 0 ]; then
    echo "[+] Key successfully added to LUKS header."
else
    echo "[-] Failed to add key. Exiting."
    exit 1
fi

# 3. Split the key using ssss
read -p "Enter the total number of admin shares (n): " TOTAL_N
read -p "Enter the threshold required to unlock (t): " THRESHOLD_T

echo "[*] Splitting the secret into $TOTAL_N shares (Threshold: $THRESHOLD_T)..."
echo "------------------------------------------------------------------"
echo "$RECOVERY_KEY" | ssss-split -t "$THRESHOLD_T" -n "$TOTAL_N" -q
echo "------------------------------------------------------------------"

echo "[!] IMPORTANT: Distribute the shares above to your admins."
echo "[!] Once you have safely stored the shares, clear your terminal history."

# Clear the variable from memory
unset RECOVERY_KEY