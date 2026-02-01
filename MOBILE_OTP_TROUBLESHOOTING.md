# 🔴 Mobile OTP Verification - Complete Troubleshooting Guide

## Current Situation
- ✅ SHA keys are correct
- ✅ google-services.json replaced
- ❌ OTP verification still not working

## 🔍 Step-by-Step Diagnosis & Fix

### STEP 1: Verify SHA Keys Are ACTUALLY Added in Firebase Console

**This is the #1 cause of failures!**

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select project: **sant-narhari-sonar**
3. Click gear icon → **Project Settings**
4. Scroll to **"Your apps"** → Click your **Android app**
5. Find **"SHA certificate fingerprints"** section
6. **VERIFY** you see these EXACT values listed:
   - SHA-1: `2C:E7:5C:56:91:46:48:48:4E:64:D5:25:60:B4:E3:BF:FC:4B:44:CF`
   - SHA-256: `D4:E7:50:BB:03:2F:76:FF:8D:05:30:27:B3:23:B3:2A:10:B9:7F:5C:D0:88:10:08:37:3B:7D:57:21:B3:B0:52`

**If they're NOT there:**
- Click **"Add fingerprint"**
- Add SHA-1 first
- Click **"Add fingerprint"** again
- Add SHA-256
- **Save**

**If they ARE there but still not working:**
- Continue to Step 2

---

### STEP 2: Verify Phone Authentication is Enabled

1. Firebase Console → **Authentication** → **Sign-in method**
2. Click on **Phone**
3. **Toggle should be ON** (Enabled)
4. If OFF, turn it ON and **Save**

---

### STEP 3: Verify google-services.json Location

**CRITICAL**: The file MUST be in the correct location!

1. Check file exists at: `android/app/google-services.json`
2. Verify file content matches Firebase Console:
   - Package name: `com.santnarhari.sant_narhari_sonar`
   - App ID: `1:732075543745:android:4f9f985d32c7c8d6d75840`

**If file is missing or wrong:**
1. Firebase Console → Project Settings → Your apps → Android app
2. Click **"Download google-services.json"**
3. Replace `android/app/google-services.json` with the downloaded file
4. **DO NOT** put it in `android/google-services.json` (wrong location!)

---

### STEP 4: Clean Build (CRITICAL)

**You MUST rebuild after replacing google-services.json!**

```bash
cd "/Users/kartikkumar/Documents/sant narhari/Sant Narhari Sonar app"

# Clean everything
flutter clean

# Remove old build artifacts
rm -rf build/
rm -rf android/app/build/
rm -rf android/.gradle/

# Get dependencies
flutter pub get

# Rebuild
flutter build apk --release
# OR for debug:
flutter run
```

**Important**: 
- Old builds contain the OLD google-services.json
- You MUST rebuild to use the new one
- Uninstall old app from device first!

---

### STEP 5: Check Which Keystore You're Using

**Are you building with debug or release keystore?**

**Debug Build** (uses `~/.android/debug.keystore`):
- SHA-1: `2C:E7:5C:56:91:46:48:48:4E:64:D5:25:60:B4:E3:BF:FC:4B:44:CF`
- SHA-256: `D4:E7:50:BB:03:2F:76:FF:8D:05:30:27:B3:23:B3:2A:10:B9:7F:5C:D0:88:10:08:37:3B:7D:57:21:B3:B0:52`

**Release Build** (uses your release keystore):
- Different SHA keys!
- You need to add release SHA keys too!

**To check which keystore you're using:**
```bash
cd android
./get_sha_keys.sh
```

**If building release APK:**
1. Get release SHA keys from the script
2. Add them to Firebase Console (in addition to debug keys)

---

### STEP 6: Verify Package Name Match

**Check these match EXACTLY:**

1. **build.gradle.kts**: `applicationId = "com.santnarhari.sant_narhari_sonar"`
2. **google-services.json**: `"package_name": "com.santnarhari.sant_narhari_sonar"`
3. **Firebase Console**: Package name should be `com.santnarhari.sant_narhari_sonar`

**All three must match EXACTLY!**

---

### STEP 7: Check Firebase Initialization

**Verify Firebase is initializing correctly:**

1. Run app in debug mode
2. Check logcat for Firebase errors:
   ```bash
   flutter run
   # Look for Firebase initialization errors
   ```

3. Check for these errors:
   - "FirebaseApp initialization failure"
   - "google-services.json not found"
   - "Package name mismatch"

---

### STEP 8: Test with Test Phone Number

**Use Firebase test numbers to bypass Play Integrity:**

1. Firebase Console → **Authentication** → **Sign-in method** → **Phone**
2. Expand **"Phone numbers for testing"**
3. Click **"Add phone number"**
4. Add: `+91 8448250988` (or your test number)
5. Set verification code: `123456`
6. **Save**

**Then in app:**
- Enter the test phone number
- Use the test code (e.g., `123456`)
- This bypasses SMS and Play Integrity

**If test numbers work but real numbers don't:**
- Issue is with Play Integrity or SMS delivery
- Not a configuration issue

---

### STEP 9: Check App Installation

**Make sure you're testing the NEW build:**

1. **Uninstall** old app completely from device
2. Install the NEW APK you just built
3. Try OTP again

**Old app = old google-services.json = won't work!**

---

### STEP 10: Verify Network & Permissions

**Check app has required permissions:**

1. Android Settings → Apps → Your App → Permissions
2. Ensure **Phone** permission is granted (if required)
3. Ensure **Internet** permission is granted

**Check network:**
- Try on WiFi
- Try on mobile data
- Check if other Firebase features work (e.g., Firestore)

---

## 🎯 Most Common Issues & Solutions

### Issue 1: "App not authorized" Error

**Cause**: SHA keys not added in Firebase Console

**Solution**:
1. Verify SHA keys are listed in Firebase Console
2. If missing, add them
3. Wait 5 minutes
4. Rebuild app

---

### Issue 2: OTP Never Arrives

**Causes**:
- Phone authentication not enabled
- Using release build but only debug SHA keys added
- SMS quota exceeded
- Wrong phone number format

**Solutions**:
1. Enable Phone Auth in Firebase Console
2. Add release SHA keys if building release
3. Check Firebase Console → Usage for quota
4. Use test phone numbers to verify

---

### Issue 3: "Invalid verification code"

**Cause**: Code expired or wrong code entered

**Solution**:
- Request new OTP
- Enter code within 60 seconds
- Use test numbers for testing

---

### Issue 4: Works on Emulator but Not Real Device

**Cause**: Different keystores (debug vs release)

**Solution**:
- Emulator uses debug keystore
- Real device might use release keystore
- Add SHA keys for BOTH keystores

---

## ✅ Complete Fix Checklist

- [ ] SHA-1 added to Firebase Console
- [ ] SHA-256 added to Firebase Console
- [ ] Phone Authentication enabled in Firebase Console
- [ ] google-services.json in correct location (`android/app/`)
- [ ] google-services.json downloaded fresh from Firebase Console
- [ ] Package name matches in all 3 places
- [ ] App completely rebuilt (`flutter clean` then rebuild)
- [ ] Old app uninstalled from device
- [ ] New APK installed
- [ ] Tested with test phone number (if available)

---

## 🚀 Quick Fix Command Sequence

```bash
# 1. Clean everything
cd "/Users/kartikkumar/Documents/sant narhari/Sant Narhari Sonar app"
flutter clean
rm -rf build/ android/app/build/ android/.gradle/

# 2. Get dependencies
flutter pub get

# 3. Verify google-services.json exists
ls -la android/app/google-services.json

# 4. Rebuild
flutter build apk --release

# 5. Install on device (uninstall old app first!)
```

---

## 📞 Still Not Working?

**If ALL steps above are done and still not working:**

1. **Check Firebase Console logs**:
   - Firebase Console → Authentication → Users
   - Look for failed attempts
   - Check error messages

2. **Check Android logcat**:
   ```bash
   adb logcat | grep -i firebase
   ```

3. **Verify Firebase project**:
   - Ensure you're using the correct Firebase project
   - Check project ID: `sant-narhari-sonar`

4. **Test with minimal code**:
   - Create a simple test app
   - Try phone auth
   - If it works, issue is in your app code

---

## 🎯 Most Likely Issue

**Based on your description, the most likely issue is:**

1. **SHA keys not actually added in Firebase Console** (even though they're correct)
2. **App not rebuilt** after replacing google-services.json
3. **Testing with old APK** that has old google-services.json

**Do Steps 1, 4, and 9 above - that should fix it!**
