#!/bin/bash

# UKI Build and Sign Script
# Unal Secure Boot Project - Phase 3
#
# Builds a Unified Kernel Image (kernel + initramfs + cmdline + os-release)
# from the currently running kernel and signs it with db.key.

set -e

KEYS_DIR="$HOME/secure-boot-project/keys"
OUT_UNSIGNED="/tmp/test-uki.efi"
OUT_SIGNED="/tmp/uki-signed.efi"
ESP_TARGET="/boot/efi/EFI/Linux/my_ubuntu.efi"
KVER="$(uname -r)"

echo "========================================="
echo " UKI Build and Sign"
echo "========================================="
echo " kernel    : /boot/vmlinuz-$KVER"
echo " initramfs : /boot/initrd.img-$KVER"
echo " keys      : $KEYS_DIR"
echo ""

echo "--- Step 0: Pre-flight checks ---"

# Key files exist?
for f in "$KEYS_DIR/db.key" "$KEYS_DIR/db.crt"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: missing $f"
        echo "       Generate keys first (see key_generation.md)."
        exit 1
    fi
done
echo "keys present in $KEYS_DIR"

# Is our db cert enrolled in UEFI db?
OUR_CN="$(openssl x509 -in "$KEYS_DIR/db.crt" -noout -subject \
          | sed -n 's|.*CN *= *||p' | head -n1)"
if efi-readvar -v db 2>/dev/null | grep -qF "$OUR_CN"; then
    echo "OK: '$OUR_CN' is enrolled in UEFI db"
else
    echo "WARNING: '$OUR_CN' NOT found in UEFI db"
    echo "         UEFI will reject the signed UKI at boot until the cert is enrolled."
    echo "         (build/sign/install will still run so the artifact is ready)"
fi
echo ""

echo "--- Plan ---"
echo " 1) Build  unsigned UKI -> $OUT_UNSIGNED"
echo " 2) Sign   with $KEYS_DIR/db.key -> $OUT_SIGNED"
echo " 3) Verify signature"
echo " 4) Install to $ESP_TARGET"
echo ""
read -r -p "Proceed with all four steps? [y/N] " ans
case "$ans" in
    y|Y|yes|YES) ;;
    *) echo "aborted by user"; exit 1 ;;
esac
echo ""

echo "--- Step 1: Build unsigned UKI ---"
sudo ukify build \
  --linux="/boot/vmlinuz-$KVER" \
  --initrd="/boot/initrd.img-$KVER" \
  --cmdline="$(sed 's|BOOT_IMAGE=[^ ]* ||' /proc/cmdline)" \
  --os-release=@/etc/os-release \
  --output="$OUT_UNSIGNED"
echo "wrote $OUT_UNSIGNED"
echo ""

echo "--- Step 2: Sign with db.key ---"
sudo sbsign \
  --key  "$KEYS_DIR/db.key" \
  --cert "$KEYS_DIR/db.crt" \
  --output "$OUT_SIGNED" \
  "$OUT_UNSIGNED"
echo "wrote $OUT_SIGNED"
echo ""

echo "--- Step 3: Verify signature ---"
sbverify --list "$OUT_SIGNED"
echo ""

echo "--- Step 4: Install to ESP ---"
sudo mkdir -p "$(dirname "$ESP_TARGET")"
if [ -f "$ESP_TARGET" ]; then
    echo "existing UKI at $ESP_TARGET:"
    sudo ls -lh "$ESP_TARGET"
    read -r -p "Overwrite? [y/N] " ans
    case "$ans" in
        y|Y|yes|YES) ;;
        *) echo "aborted before install — signed file kept at $OUT_SIGNED"; exit 1 ;;
    esac
fi
sudo cp "$OUT_SIGNED" "$ESP_TARGET"
echo "installed at $ESP_TARGET"
echo ""

echo "========================================="
echo " Done. UKI is in place."
echo " (UEFI boot entry: set once with 'efibootmgr --create')"
echo "========================================="