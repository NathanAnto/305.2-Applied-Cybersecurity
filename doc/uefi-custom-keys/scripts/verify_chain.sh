#!/bin/bash

# Secure Boot Certificate Chain Verification Script
# Unal Secure Boot Project - Phase 3

echo "========================================="
echo " Secure Boot Certificate Chain Verification"
echo "========================================="
echo ""

echo "--- Step 1: Subject/Issuer hierarchy ---"
echo ""

echo "[PK]"
openssl x509 -in PK.crt -noout -subject -issuer
echo ""

echo "[KEK]"
openssl x509 -in KEK.crt -noout -subject -issuer
echo ""

echo "[db]"
openssl x509 -in db.crt -noout -subject -issuer
echo ""


echo "--- Step 2: Negative test ---"
echo ""

echo "[Test] Is an invalid chain rejected?"
echo "(Attempting to verify db against PK directly - should fail)"
openssl verify -CAfile PK.crt -partial_chain db.crt 2>&1 || echo "REJECTED (expected behavior)"
echo ""

echo "========================================="
echo " Verification complete"
echo "========================================="