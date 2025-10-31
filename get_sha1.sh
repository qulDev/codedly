#!/bin/bash

echo "🔍 Getting Android SHA-1 Certificate Fingerprint..."
echo ""

cd /home/rizqullah/Development/Flutter/codedly/android

if [ -f "gradlew" ]; then
    echo "Running gradlew signingReport..."
    echo ""
    ./gradlew signingReport | grep -A 2 "Variant: debug" | grep SHA1
    echo ""
    echo "✅ Copy the SHA1 value above and use it in Google Cloud Console"
    echo ""
else
    echo "❌ gradlew not found. Make sure you're in a Flutter project."
    echo ""
    echo "Alternative: Run the app once, then use:"
    echo "keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1"
fi
