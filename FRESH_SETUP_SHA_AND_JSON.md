# 🔄 Fresh Setup: SHA Keys & google-services.json

## ✅ OTP Verification Routing (Verified Correct)

**Current Flow:**
1. User opens app → `OnboardingScreen` or `LoginSignupScreen`
2. User taps "Continue with Phone" → Navigates to `PhoneOtpScreen`
3. User enters phone number → Clicks "Send OTP"
4. `FirebaseAuthService.sendPhoneOtp()` called
5. OTP sent → Screen switches to OTP input view
6. User enters OTP → Clicks "Verify & Sign In"
7. `FirebaseAuthService.verifyOtpAndSignIn()` called
8. Success → Navigates to `MainShellScreen` (clears navigation stack)

**Routing is CORRECT ✅** - No changes needed!

---

## 🔑 FRESH SHA KEYS (Delete Old & Add These)

### Your Current SHA Keys:

**SHA-1:**
```
2C:E7:5C:56:91:46:48:48:4E:64:D5:25:60:B4:E3:BF:FC:4B:44:CF
```

**SHA-256:**
```
D4:E7:50:BB:03:2F:76:FF:8D:05:30:27:B3:23:B3:2A:10:B9:7F:5C:D0:88:10:08:37:3B:7D:57:21:B3:B0:52
```

---

## 📋 STEP-BY-STEP: Delete Old & Add Fresh SHA Keys

### Step 1: Delete Old SHA Keys

1. Go to Firebase Console: https://console.firebase.google.com/project/sant-narhari-sonar/settings/general
2. Scroll to **"Your apps"** → Click **Android app** (`com.santnarhari.sant_narhari_sonar`)
3. Find **"SHA certificate fingerprints"** section
4. **Delete ALL existing SHA keys**:
   - Click the **trash/delete icon** next to each SHA key
   - Confirm deletion
   - Delete both SHA-1 and SHA-256 if present

### Step 2: Add Fresh SHA Keys

**Still in the same page:**

1. Click **"Add fingerprint"** button
2. Paste this **SHA-1**:
   ```
   2C:E7:5C:56:91:46:48:48:4E:64:D5:25:60:B4:E3:BF:FC:4B:44:CF
   ```
3. Click **"Add fingerprint"** button again
4. Paste this **SHA-256**:
   ```
   D4:E7:50:BB:03:2F:76:FF:8D:05:30:27:B3:23:B3:2A:10:B9:7F:5C:D0:88:10:08:37:3B:7D:57:21:B3:B0:52
   ```
5. **Save** (if there's a save button)

**Wait 1-2 minutes** for changes to propagate.

---

## 📄 STEP-BY-STEP: Download Fresh google-services.json

### Step 1: Download New File

1. **Still in Firebase Console** → Project Settings → Your apps → Android app
2. Click **"Download google-services.json"** button (or gear icon → Download)
3. **Save** the file to your Downloads folder

### Step 2: Replace Old File

1. **Delete** old file:
   ```bash
   rm "/Users/kartikkumar/Documents/sant narhari/Sant Narhari Sonar app/android/app/google-services.json"
   ```

2. **Copy** new file to correct location:
   ```bash
   cp ~/Downloads/google-services.json "/Users/kartikkumar/Documents/sant narhari/Sant Narhari Sonar app/android/app/google-services.json"
   ```

**OR manually:**
- Open Downloads folder
- Find `google-services.json`
- Copy it
- Go to: `android/app/` folder
- Paste and replace existing file

### Step 3: Verify File Content

**Check the file has:**
- Package name: `com.santnarhari.sant_narhari_sonar`
- Project ID: `sant-narhari-sonar`
- App ID: `1:732075543745:android:4f9f985d32c7c8d6d75840`

---

## 🔄 REBUILD APP

**After replacing SHA keys and google-services.json:**

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

**Then:**
- **Uninstall** old app from device completely
- **Install** NEW APK
- Test OTP

---

## ✅ VERIFICATION CHECKLIST

### Firebase Console:
- [ ] Old SHA keys deleted
- [ ] Fresh SHA-1 added: `2C:E7:5C:56:91:46:48:48:4E:64:D5:25:60:B4:E3:BF:FC:4B:44:CF`
- [ ] Fresh SHA-256 added: `D4:E7:50:BB:03:2F:76:FF:8D:05:30:27:B3:23:B3:2A:10:B9:7F:5C:D0:88:10:08:37:3B:7D:57:21:B3:B0:52`
- [ ] Phone Authentication enabled (Authentication → Sign-in method → Phone → ON)

### Files:
- [ ] Old `google-services.json` deleted
- [ ] New `google-services.json` downloaded from Firebase Console
- [ ] New `google-services.json` placed in `android/app/` folder
- [ ] File verified (package name matches)

### Rebuild:
- [ ] App cleaned (`flutter clean`)
- [ ] App rebuilt (`flutter build apk` or `flutter run`)
- [ ] Old app uninstalled from device
- [ ] New APK installed

---

## 🧪 TESTING

### Test OTP Flow:

1. Open app
2. Navigate to Phone Login screen
3. Enter phone: `8448250988`
4. Click "Send OTP"
5. **Should see**: "OTP sent. Check your SMS."
6. Enter OTP code
7. Click "Verify & Sign In"
8. **Should navigate** to MainShellScreen

**If error:**
- Check exact error message
- Verify Phone Auth is enabled
- Verify SHA keys are added correctly
- Verify google-services.json is in correct location

---

## 📞 QUICK LINKS

- **Firebase Console**: https://console.firebase.google.com/project/sant-narhari-sonar/settings/general
- **Phone Auth**: https://console.firebase.google.com/project/sant-narhari-sonar/authentication/providers
- **Download google-services.json**: https://console.firebase.google.com/project/sant-narhari-sonar/settings/general

---

## 🎯 SUMMARY

**Do These Steps:**
1. ✅ Delete old SHA keys in Firebase Console
2. ✅ Add fresh SHA keys (provided above)
3. ✅ Download fresh google-services.json from Firebase Console
4. ✅ Replace old google-services.json in `android/app/`
5. ✅ Rebuild app (`flutter clean` then rebuild)
6. ✅ Uninstall old app and install new APK
7. ✅ Test OTP verification

**Routing is already correct - no code changes needed!**
