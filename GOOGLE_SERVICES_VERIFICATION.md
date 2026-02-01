# Google Services JSON Verification ✅

## File Replacement Complete

✅ **Replaced**: `android/app/google-services.json` with the new file from Firebase Console

## Configuration Verification

### ✅ Package Name Match
- **google-services.json**: `com.santnarhari.sant_narhari_sonar`
- **build.gradle.kts**: `com.santnarhari.sant_narhari_sonar`
- **Status**: ✅ **MATCHES PERFECTLY**

### ✅ Project Configuration
- **Project ID**: `sant-narhari-sonar`
- **Project Number**: `732075543745`
- **App ID**: `1:732075543745:android:4f9f985d32c7c8d6d75840`
- **API Key**: `AIzaSyBCw1JnfkpkChYkpu_h76Yl8G9rNnicXHc`
- **Storage Bucket**: `sant-narhari-sonar.firebasestorage.app`

### ✅ SHA Fingerprints (Current)
**Debug Keystore** (for testing/emulator):
- **SHA-1**: `2C:E7:5C:56:91:46:48:48:4E:64:D5:25:60:B4:E3:BF:FC:4B:44:CF`
- **SHA-256**: `D4:E7:50:BB:03:2F:76:FF:8D:05:30:27:B3:23:B3:2A:10:B9:7F:5C:D0:88:10:08:37:3B:7D:57:21:B3:B0:52`

**⚠️ Important**: These SHA keys must be added in Firebase Console (not in the JSON file). The JSON file doesn't contain SHA keys - they're stored separately in Firebase Console.

## OTP Verification Checklist

### ✅ Code Configuration
- ✅ `google-services.json` updated and in correct location (`android/app/`)
- ✅ Package name matches in build.gradle.kts
- ✅ Firebase BOM and Auth dependencies configured
- ✅ MainActivity.kt configured for debug builds

### ⚠️ Firebase Console Configuration (Manual Steps Required)

1. **SHA Fingerprints** (CRITICAL):
   - Go to Firebase Console → Project Settings → Your apps → Android app
   - Verify SHA-1 and SHA-256 are added:
     - SHA-1: `2C:E7:5C:56:91:46:48:48:4E:64:D5:25:60:B4:E3:BF:FC:4B:44:CF`
     - SHA-256: `D4:E7:50:BB:03:2F:76:FF:8D:05:30:27:B3:23:B3:2A:10:B9:7F:5C:D0:88:10:08:37:3B:7D:57:21:B3:B0:52`
   - If missing, click "Add fingerprint" and add them

2. **Phone Authentication**:
   - Firebase Console → Authentication → Sign-in method
   - Verify **Phone** is **Enabled**
   - Check that **reCAPTCHA Enterprise** is configured (for web)

3. **Authorized Domains** (for web):
   - Firebase Console → Authentication → Settings → Authorized domains
   - Verify these domains are present:
     - `localhost`
     - `sonarcommunity.com`
     - `www.sonarcommunity.com`
     - `sant-narhari-sonar.web.app`
     - `sant-narhari-sonar.firebaseapp.com`

## Next Steps

1. **Rebuild the app**:
   ```bash
   flutter clean
   flutter build apk --release
   ```

2. **Test OTP Verification**:
   - Try phone login on Android app
   - Try phone login on web app
   - Verify no "app-not-authorized" errors

3. **If OTP still fails**:
   - Double-check SHA keys are in Firebase Console
   - Verify Phone Auth is enabled
   - Check Firebase Console for any error logs
   - Ensure you're using the correct keystore (debug vs release)

## Summary

✅ **google-services.json**: Updated and verified
✅ **Package Name**: Matches correctly
✅ **SHA Keys**: Retrieved and ready to add to Firebase Console
✅ **Build Configuration**: Correct

**Remaining**: Verify SHA keys are added in Firebase Console (manual step)
