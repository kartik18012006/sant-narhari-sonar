# ✅ google-services.json Replacement Complete

## File Replacement

✅ **Replaced**: `android/app/google-services.json` with new file from Firebase Console

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

### ✅ JSON Validation
- File is valid JSON ✅
- Structure is correct ✅
- All required fields present ✅

## Next Steps

### 1. Rebuild App (CRITICAL)

**You MUST rebuild after replacing google-services.json!**

```bash
cd "/Users/kartikkumar/Documents/sant narhari/Sant Narhari Sonar app"

# Clean everything
flutter clean
rm -rf build/ android/app/build/ android/.gradle/

# Get dependencies
flutter pub get

# Rebuild
flutter build apk --release
# OR for testing:
flutter run
```

### 2. Verify SHA Keys Are Added

**Make sure SHA keys are in Firebase Console:**

1. Go to: https://console.firebase.google.com/project/sant-narhari-sonar/settings/general
2. Scroll to **"Your apps"** → Click **Android app**
3. Verify SHA keys are listed:
   - SHA-1: `2C:E7:5C:56:91:46:48:48:4E:64:D5:25:60:B4:E3:BF:FC:4B:44:CF`
   - SHA-256: `D4:E7:50:BB:03:2F:76:FF:8D:05:30:27:B3:23:B3:2A:10:B9:7F:5C:D0:88:10:08:37:3B:7D:57:21:B3:B0:52`

### 3. Verify Phone Authentication Enabled

1. Firebase Console → **Authentication** → **Sign-in method**
2. Click **Phone**
3. **Toggle must be ON** (Enabled)
4. If OFF → Turn it ON → **Save**

### 4. Install New App

**After rebuilding:**
- **Uninstall** old app from device completely
- **Install** NEW APK
- Test OTP verification

## ✅ Verification Checklist

- [x] google-services.json replaced ✅
- [x] Package name matches ✅
- [x] JSON is valid ✅
- [ ] App rebuilt (`flutter clean` then rebuild)
- [ ] SHA keys added in Firebase Console
- [ ] Phone Authentication enabled in Firebase Console
- [ ] Old app uninstalled from device
- [ ] New APK installed
- [ ] OTP tested

## 🧪 Testing

After completing all steps:

1. Open app
2. Navigate to Phone Login
3. Enter phone number: `8448250988`
4. Click "Send OTP"
5. **Should see**: "OTP sent. Check your SMS."
6. Enter OTP code
7. Click "Verify & Sign In"
8. **Should navigate** to MainShellScreen

## 📝 Summary

✅ **google-services.json**: Replaced and verified
✅ **Configuration**: All correct
⏳ **Next**: Rebuild app and verify SHA keys + Phone Auth enabled

**The file replacement is complete. Now rebuild the app and test!**
