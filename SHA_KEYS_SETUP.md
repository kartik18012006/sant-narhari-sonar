# SHA Keys Setup for Firebase Authentication

## ⚠️ Important: SHA Keys Are NOT Automatically Integrated

The app **does NOT** automatically retrieve or register SHA keys. You must **manually add them** to Firebase Console.

## Why SHA Keys Are Needed

Firebase Authentication requires SHA-1 and SHA-256 fingerprints to verify that your app is authorized to use Firebase services. Without them, you'll see errors like:
- "This app is not authorized to use Firebase Authentication"
- "app-not-authorized" errors

## Quick Setup Guide

### Step 1: Get Your SHA Keys

**Option A: Use the Helper Script (Recommended)**

```bash
cd android
./get_sha_keys.sh
```

This script will automatically:
- Find your debug keystore and show SHA-1/SHA-256
- Find your release keystore (if configured) and show SHA-1/SHA-256
- Display them in an easy-to-copy format

**Option B: Manual Command**

**For Debug Builds** (testing/emulator):
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**For Release Builds** (production):
```bash
keytool -list -v -keystore <path-to-your-release.keystore> -alias <your-alias>
```

Look for lines starting with `SHA1:` and `SHA256:` in the output.

### Step 2: Add SHA Keys to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **sant-narhari-sonar**
3. Click the **gear icon** → **Project settings**
4. Scroll to **Your apps** section
5. Click on your **Android app** (package: `com.santnarhari.sant_narhari_sonar`)
6. Find **SHA certificate fingerprints** section
7. Click **Add fingerprint**
8. Paste your **SHA-1** fingerprint
9. Click **Add fingerprint** again
10. Paste your **SHA-256** fingerprint
11. **Important**: If you use both debug and release builds, add SHA keys for BOTH keystores
12. Click **Save**

### Step 3: Update google-services.json

After adding SHA keys:

1. In Firebase Console, go to **Project settings** → **Your apps** → Android app
2. Click **Download google-services.json** (or use the download button)
3. Replace `android/app/google-services.json` with the new file
4. Rebuild your app: `flutter clean && flutter build apk`

## Debug vs Release SHA Keys

### Debug Keystore
- **Location**: `~/.android/debug.keystore`
- **Used for**: Testing, emulator, development builds
- **When to add**: Always add these for development

### Release Keystore
- **Location**: `android/app/upload-keystore.jks` (or your custom keystore)
- **Used for**: Production builds, Play Store releases
- **When to add**: Add these when you build release/production APKs

**⚠️ Important**: Add SHA keys for **BOTH** if you use both debug and release builds!

## Troubleshooting

### "This app is not authorized" Error

1. **Check if SHA keys are added**:
   - Firebase Console → Project Settings → Your apps → Android app
   - Verify SHA-1 and SHA-256 are listed

2. **Verify you're using the correct keystore**:
   - Debug builds use `~/.android/debug.keystore`
   - Release builds use your release keystore
   - Make sure you added SHA keys for the keystore you're actually using

3. **Update google-services.json**:
   - Download fresh `google-services.json` from Firebase Console
   - Replace `android/app/google-services.json`
   - Rebuild: `flutter clean && flutter build apk`

4. **Verify package name**:
   - App package: `com.santnarhari.sant_narhari_sonar`
   - Must match exactly in Firebase Console

### SHA Keys Changed

If you:
- Created a new keystore
- Lost your keystore and created a new one
- Changed your release signing configuration

Then you **must**:
1. Get new SHA keys using the script or commands above
2. Add the new SHA keys to Firebase Console
3. Download new `google-services.json`
4. Rebuild your app

## Verification

After adding SHA keys, verify they're correct:

1. Run: `cd android && ./get_sha_keys.sh`
2. Compare the output with what's in Firebase Console
3. They should match exactly (case-insensitive)

## Summary

- ✅ SHA keys are **NOT** automatically integrated
- ✅ You **must manually add** them to Firebase Console
- ✅ Use `android/get_sha_keys.sh` script to get them easily
- ✅ Add SHA keys for **both** debug and release if you use both
- ✅ Download new `google-services.json` after adding SHA keys
- ✅ Rebuild your app after updating `google-services.json`
