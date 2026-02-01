#!/bin/bash
# Get SHA-1 and SHA-256 fingerprints for Firebase Authentication
# Run this script from the project root or android directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=============================================="
echo "  Get SHA Fingerprints for Firebase Auth"
echo "=============================================="
echo ""

# Check for release keystore
KEY_PROPERTIES="app/key.properties"
RELEASE_KEYSTORE=""
RELEASE_ALIAS=""
RELEASE_PASSWORD=""

if [ -f "$KEY_PROPERTIES" ]; then
    echo "Found release keystore configuration."
    source "$KEY_PROPERTIES"
    RELEASE_KEYSTORE="$storeFile"
    RELEASE_ALIAS="$keyAlias"
    RELEASE_PASSWORD="$storePassword"
    
    if [ -f "$RELEASE_KEYSTORE" ]; then
        echo "✓ Release keystore found: $RELEASE_KEYSTORE"
    else
        echo "⚠️  Release keystore file not found: $RELEASE_KEYSTORE"
        RELEASE_KEYSTORE=""
    fi
else
    echo "No release keystore found (this is OK for debug builds)"
fi

echo ""
echo "--------------------------------------------"
echo "1. DEBUG KEYSTORE SHA FINGERPRINTS"
echo "--------------------------------------------"
echo "These are for debug builds and emulator testing:"
echo ""

DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
if [ -f "$DEBUG_KEYSTORE" ]; then
    echo "SHA-1:"
    keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -A 1 "SHA1:" | grep -v "^--" | sed 's/.*SHA1: //' | head -1
    
    echo ""
    echo "SHA-256:"
    keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -A 1 "SHA256:" | grep -v "^--" | sed 's/.*SHA256: //' | head -1
else
    echo "⚠️  Debug keystore not found at $DEBUG_KEYSTORE"
    echo "   This is normal if you haven't built a debug app yet."
fi

if [ -n "$RELEASE_KEYSTORE" ] && [ -f "$RELEASE_KEYSTORE" ]; then
    echo ""
    echo "--------------------------------------------"
    echo "2. RELEASE KEYSTORE SHA FINGERPRINTS"
    echo "--------------------------------------------"
    echo "These are for production/release builds:"
    echo ""
    
    echo "SHA-1:"
    keytool -list -v -keystore "$RELEASE_KEYSTORE" -alias "$RELEASE_ALIAS" -storepass "$RELEASE_PASSWORD" -keypass "$RELEASE_PASSWORD" 2>/dev/null | grep -A 1 "SHA1:" | grep -v "^--" | sed 's/.*SHA1: //' | head -1
    
    echo ""
    echo "SHA-256:"
    keytool -list -v -keystore "$RELEASE_KEYSTORE" -alias "$RELEASE_ALIAS" -storepass "$RELEASE_PASSWORD" -keypass "$RELEASE_PASSWORD" 2>/dev/null | grep -A 1 "SHA256:" | grep -v "^--" | sed 's/.*SHA256: //' | head -1
fi

echo ""
echo "--------------------------------------------"
echo "NEXT STEPS:"
echo "--------------------------------------------"
echo "1. Copy the SHA-1 and SHA-256 fingerprints above"
echo "2. Go to Firebase Console:"
echo "   https://console.firebase.google.com/"
echo "3. Select your project: sant-narhari-sonar"
echo "4. Go to: Project Settings → Your apps → Android app"
echo "5. Click 'Add fingerprint' and paste each SHA key"
echo "6. Save and rebuild your app"
echo ""
echo "⚠️  IMPORTANT:"
echo "   - Add BOTH debug AND release SHA keys if you use both"
echo "   - Debug keys are for testing/emulator"
echo "   - Release keys are for production/Play Store builds"
echo ""
