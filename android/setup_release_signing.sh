#!/bin/bash
# Setup release signing for Sant Narhari Sonar app
# Run this script from the project root or android directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

KEYSTORE_FILE="upload-keystore.jks"
KEY_PROPERTIES="key.properties"
KEY_ALIAS="upload"

if [ -f "$KEYSTORE_FILE" ]; then
    echo "Release keystore already exists at $KEYSTORE_FILE"
    echo "If you need to create a new one, delete it first and run this script again."
    exit 0
fi

echo "=============================================="
echo "  Sant Narhari Sonar - Release Signing Setup"
echo "=============================================="
echo ""
echo "You will create a keystore that signs your app for Play Store."
echo "IMPORTANT: Save the password - you need it for ALL future updates!"
echo ""

if [ -n "$KEYSTORE_PASSWORD" ]; then
    echo "Using password from KEYSTORE_PASSWORD environment variable."
    STORE_PASS="$KEYSTORE_PASSWORD"
else
    read -sp "Enter a password for your release keystore: " STORE_PASS
    echo ""
    read -sp "Confirm password: " STORE_PASS_CONFIRM
    echo ""
    if [ "$STORE_PASS" != "$STORE_PASS_CONFIRM" ]; then
        echo "Error: Passwords don't match."
        exit 1
    fi
fi

echo ""
echo "Creating release keystore..."

keytool -genkeypair -v \
    -keystore "$KEYSTORE_FILE" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$KEY_ALIAS" \
    -storepass "$STORE_PASS" \
    -keypass "$STORE_PASS" \
    -dname "CN=Sant Narhari Sonar, OU=Development, O=Sant Narhari, L=City, ST=State, C=IN"

echo ""
echo "Creating key.properties..."

cat > "$KEY_PROPERTIES" << EOF
storePassword=$STORE_PASS
keyPassword=$STORE_PASS
keyAlias=$KEY_ALIAS
storeFile=$KEYSTORE_FILE
EOF

echo ""
echo "✓ Done! Release signing is configured."
echo ""
echo "NEXT STEPS:"
echo "1. Run: flutter build appbundle"
echo "2. Upload the new app-release.aab to Play Console"
echo ""
echo "⚠️  BACKUP YOUR KEYSTORE: Copy $KEYSTORE_FILE to a safe place!"
echo "    Without it, you cannot update your app on Play Store."
echo ""
