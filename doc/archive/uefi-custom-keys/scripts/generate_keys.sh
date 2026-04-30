#!/bin/bash

# Secure Boot Key Generation Script
# Unal Secure Boot Project - Phase 3
#
# Generates GUID + PK, KEK, db (private keys + X.509 certificates).
# Output: ~/secure-boot-project/keys/

set -e

KEYS_DIR="$HOME/secure-boot-project/keys"
DAYS=3650

mkdir -p "$KEYS_DIR"
cd "$KEYS_DIR"

echo "========================================="
echo " Secure Boot Key Generation"
echo "========================================="
echo " Output: $KEYS_DIR"
echo ""

echo "--- Step 1: GUID ---"
uuidgen > GUID.txt
echo "GUID: $(cat GUID.txt)"
echo ""

echo "--- Step 2: PK (Platform Key, self-signed) ---"
openssl genrsa -out PK.key 2048
openssl req -new -key PK.key -out PK.csr -subj "/CN=Unal Platform Key"
openssl req -x509 -key PK.key -in PK.csr -out PK.crt -days $DAYS -sha256
echo ""

echo "--- Step 3: KEK (signed by PK) ---"
openssl genrsa -out KEK.key 2048
openssl req -new -key KEK.key -out KEK.csr -subj "/CN=Unal Key Exchange Key"
openssl x509 -req -in KEK.csr -CA PK.crt -CAkey PK.key -CAcreateserial \
    -out KEK.crt -days $DAYS -sha256
echo ""

echo "--- Step 4: db (signed by KEK) ---"
openssl genrsa -out db.key 2048
openssl req -new -key db.key -out db.csr -subj "/CN=Unal Signature Database"
openssl x509 -req -in db.csr -CA KEK.crt -CAkey KEK.key -CAcreateserial \
    -out db.crt -days $DAYS -sha256
echo ""

echo "--- Step 5: Tighten permissions ---"
chmod 700 "$KEYS_DIR"
chmod 600 "$KEYS_DIR"/*.key
echo "folder 700, .key files 600"
echo ""

echo "========================================="
echo " Done. Files in $KEYS_DIR:"
echo "========================================="
ls -la
