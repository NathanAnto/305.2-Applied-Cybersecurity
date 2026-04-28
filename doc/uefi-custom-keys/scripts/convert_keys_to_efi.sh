#!/bin/bash

# EFI Format Conversion Script
# Unal Secure Boot Project - Phase 3
#
# Converts X.509 certificates to UEFI ESL format and creates
# authenticated (.auth) files ready for efi-updatevar.

set -e

KEYS_DIR="$HOME/secure-boot-project/keys"
cd "$KEYS_DIR"

GUID=$(cat GUID.txt)

echo "========================================="
echo " EFI Format Conversion"
echo "========================================="
echo " GUID: $GUID"
echo ""

echo "--- Step 1: X.509 -> ESL ---"
cert-to-efi-sig-list -g "$GUID" PK.crt  PK.esl
cert-to-efi-sig-list -g "$GUID" KEK.crt KEK.esl
cert-to-efi-sig-list -g "$GUID" db.crt  db.esl
echo "PK.esl, KEK.esl, db.esl created"
echo ""

echo "--- Step 2: ESL -> AUTH ---"
sign-efi-sig-list -g "$GUID" -k PK.key  -c PK.crt  PK  PK.esl  PK.auth
sign-efi-sig-list -g "$GUID" -k PK.key  -c PK.crt  KEK KEK.esl KEK.auth
sign-efi-sig-list -g "$GUID" -k KEK.key -c KEK.crt db  db.esl  db.auth
echo "PK.auth, KEK.auth, db.auth created"
echo ""

echo "========================================="
echo " Done. Ready for efi-updatevar."
echo "========================================="
