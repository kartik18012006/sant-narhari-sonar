# 🚨 Mobile OTP Quick Fix - Do These Steps NOW

## ⚡ Most Common Issues (Check These First!)

### Issue #1: SHA Keys Not Actually Added in Firebase Console

**Even if SHA keys are "correct", they must be ADDED in Firebase Console!**

**VERIFY RIGHT NOW:**
1. Go to: https://console.firebase.google.com/project/sant-narhari-sonar/settings/general
2. Scroll to **"Your apps"** → Click **Android app**
3. Look at **"SHA certificate fingerprints"** section
4. **Do you see these listed?**
   - `2C:E7:5C:56:91:46:48:48:4E:64:D5:25:60:B4:E3:BF:FC:4B:44:CF`
   - `D4:E7:50:BB:03:2F:76:FF:8D:05:30:27:B3:23:B3:2A:10:B9:7F:5C:D0:88:10:08:37:3B:7D:57:21:B3:B0:52`

**If NO → Add them NOW:**
- Click **"Add fingerprint"**
- Paste SHA-1
- Click **"Add fingerprint"** again
- Paste SHA-256
- **Save**

---

### Issue #2: App Not Rebuilt After Replacing google-services.json

**CRITICAL**: Old APK = old google-services.json = won't work!

**DO THIS NOW:**
```bash
cd "/Users/kartikkumar/Documents/sant narhari/Sant Narhari Sonar app"

# 1. Clean everything
flutter clean
rm -rf build/ android/app/build/

# 2. Rebuild
flutter build apk --release
# OR for testing:
flutter run
```

**Then:**
- **Uninstall** old app from device
- **Install** the NEW APK
- Try OTP again

---

### Issue #3: Phone Authentication Not Enabled

**VERIFY:**
1. Firebase Console → **Authentication** → **Sign-in method**
2. Click **Phone**
3. **Toggle must be ON** (Enabled)
4. If OFF, turn it ON and **Save**

---

### Issue #4: Testing with Wrong Keystore

**Are you building DEBUG or RELEASE?**

**Debug build** (flutter run):
- Uses: `~/.android/debug.keystore`
- SHA keys: The ones we have ✅

**Release build** (flutter build apk --release):
- Uses: Your release keystore
- SHA keys: **DIFFERENT!**

**Check which keystore:**
```bash
cd android
./get_sha_keys.sh
```

**If building release:**
- Get release SHA keys from script
- Add them to Firebase Console too!

---

## ✅ Complete Fix Checklist (Do ALL)

- [ ] **SHA-1 added to Firebase Console** ← CHECK THIS FIRST!
- [ ] **SHA-256 added to Firebase Console** ← CHECK THIS FIRST!
- [ ] **Phone Authentication enabled** in Firebase Console
- [ ] **google-services.json** in `android/app/` (verified ✅)
- [ ] **App rebuilt** with `flutter clean` then rebuild
- [ ] **Old app uninstalled** from device
- [ ] **New APK installed**
- [ ] **Tested** with phone number

---

## 🎯 Most Likely Problem

**90% chance it's one of these:**

1. **SHA keys not actually added in Firebase Console** (even though correct)
2. **App not rebuilt** after replacing google-services.json
3. **Testing with old APK**

**Do these 3 things and it should work!**

---

## 🧪 Quick Test

**Use Firebase test numbers to verify:**

1. Firebase Console → Authentication → Sign-in method → Phone
2. Expand **"Phone numbers for testing"**
3. Add: `+91 8448250988` with code `123456`
4. **Save**

**In app:**
- Enter: `8448250988`
- Use code: `123456`

**If test number works:**
- Configuration is correct!
- Issue is with SMS delivery or Play Integrity

**If test number doesn't work:**
- Configuration issue
- Check SHA keys and rebuild

---

## 📞 Still Not Working?

**After doing ALL steps above:**

1. Check exact error message in app
2. Check Firebase Console → Authentication → Users (for failed attempts)
3. Run: `adb logcat | grep -i firebase` (to see Firebase errors)

**Share the exact error message and I'll help debug further!**
