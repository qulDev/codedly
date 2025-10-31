#!/bin/bash

echo "======================================"
echo "Getting SHA-1 for Debug Keystore"
echo "======================================"
echo ""

# Debug keystore SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1

echo ""
echo "======================================"
echo "Copy the SHA1 fingerprint above and paste it in Google Cloud Console"
echo "======================================"
