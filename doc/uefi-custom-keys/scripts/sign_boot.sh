#!/bin/bash

# GRUB + Kernel Signing Script
# Unal Secure Boot Project - Phase 3
#
# Signs grubx64.efi and the current kernel with db.key.
# GRUB's existing Canonical signature is stripped first so only our
# signature remains. Kernel keeps its existing Canonical signature
# in addition to ours (sbsign appends).

set -e

KEYS_DIR="$HOME/secure-boot-project/keys"
GRUB_EFI="/boot/efi/EFI/ubuntu/grubx64.efi"
KERNEL="/boot/vmlinuz-$(uname -r)"

echo "========================================="
echo " Sign Boot Components with db.key"
echo "========================================="
echo " GRUB:   $GRUB_EFI"
echo " Kernel: $KERNEL"
echo ""

echo "--- Step 1: GRUB (strip + re-sign) ---"
sudo sbattach --remove "$GRUB_EFI"
sudo sbsign --key "$KEYS_DIR/db.key" --cert "$KEYS_DIR/db.crt" \
    --output "$GRUB_EFI" "$GRUB_EFI"
sudo sbverify --cert "$KEYS_DIR/db.crt" "$GRUB_EFI"
echo ""

echo "--- Step 2: Kernel (append) ---"
sudo sbsign --key "$KEYS_DIR/db.key" --cert "$KEYS_DIR/db.crt" \
    --output "$KERNEL" "$KERNEL"
sudo sbverify --cert "$KEYS_DIR/db.crt" "$KERNEL"
echo ""

echo "========================================="
echo " Done. GRUB and kernel signed."
echo "========================================="
