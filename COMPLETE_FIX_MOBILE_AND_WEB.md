# 🚨 COMPLETE FIX: Mobile + Web OTP Verification

## Current Errors

### Mobile App Error:
- "Firebase Authentication authorization error"
- Needs: SHA keys + google-services.json verification

### Web App Error:
- "Failed to initialize reCAPTCHA Enterprise config"
- "400 Bad Request" from identitytoolkit.googleapis.com
- Needs: Identity Toolkit API + reCAPTCHA configuration

---

## ✅ STEP-BY-STEP FIX (Do ALL Steps)

### STEP 1: Enable Identity Toolkit API (Web - CRITICAL)

**This is REQUIRED for web OTP to work!**

1. Click this direct link: https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=sant-narhari-sonar
2. Click **"Enable"** button
3. Wait 30 seconds for it to activate

**OR manually:**
- Google Cloud Console → APIs & Services → Library
- Search: "Identity Toolkit API"
- Click "Enable"

---

### STEP 2: Add SHA Keys to Firebase Console (Mobile - CRITICAL)

**Your current SHA keys:**
- **SHA-1**: `2C:E7:5C:56:91:46:48:48:4E:64:D5:25:60:B4:E3:BF:FC:4B:44:CF`
- **SHA-256**: `D4:E7:50:BB:03:2F:76:FF:8D:05:30:27:B3:23:B3:2A:10:B9:7F:5C:D0:88:10:08:37:3B:7D:57:21:B3:B0:52`

**Steps:**
1. Go to Firebase Console: https://console.firebase.google.com/
2. Select project: **sant-narhari-sonar**
3. Click gear icon → **Project Settings**
4. Scroll to **"Your apps"** → Click your **Android app**
5. Find **"SHA certificate fingerprints"** section
6. Click **"Add fingerprint"**
7. Paste SHA-1: `2C:E7:5C:56:91:46:48:48:4E:64:D5:25:60:B4:E3:BF:FC:4B:44:CF`
8. Click **"Add fingerprint"** again
9. Paste SHA-256: `D4:E7:50:BB:03:2F:76:FF:8D:05:30:27:B3:23:B3:2A:10:B9:7F:5C:D0:88:10:08:37:3B:7D:57:21:B3:B0:52`
10. **Save**

---

### STEP 3: Enable Domain Verification on reCAPTCHA (Web - CRITICAL)

1. Firebase Console → **Authentication** → **Settings** → **reCAPTCHA**
2. Under **"Configured platform site keys"**, find the **Web** key(s)
3. Click on the key showing **"Domain verification disabled"**
4. Click **"Enable domain verification"** or **"Verify domains"**
5. Add these domains (one by one):
   - `sonarcommunity.com`
   - `www.sonarcommunity.com`
   - `localhost` (for development)
   - `sant-narhari-sonar.web.app`
   - `sant-narhari-sonar.firebaseapp.com`
6. **Save**

---

### STEP 4: Verify Authorized Domains (Web)

1. Firebase Console → **Authentication** → **Settings** → **Authorized domains**
2. Ensure these are listed:
   - ✅ `localhost`
   - ✅ `sonarcommunity.com`
   - ✅ `www.sonarcommunity.com`
   - ✅ `sant-narhari-sonar.web.app`
   - ✅ `sant-narhari-sonar.firebaseapp.com`
3. If any are missing, click **"Add domain"** and add them

---

### STEP 5: Verify Phone Authentication is Enabled

1. Firebase Console → **Authentication** → **Sign-in method**
2. Click on **Phone**
3. Ensure **Phone** is **Enabled** (toggle should be ON)
4. Ensure **reCAPTCHA Enterprise** is selected (not reCAPTCHA v2)
5. **Save**

---

### STEP 6: Download Latest google-services.json (Mobile)

1. Firebase Console → **Project Settings** → **Your apps** → **Android app**
2. Click **"Download google-services.json"** button
3. Replace `android/app/google-services.json` with the new file
4. **Important**: Make sure the file is saved correctly

---

### STEP 7: Rebuild Both Apps

**For Mobile:**
```bash
cd "/Users/kartikkumar/Documents/sant narhari/Sant Narhari Sonar app"
flutter clean
flutter build apk --release
# Or flutter build appbundle --release
```

**For Web:**
```bash
flutter clean
flutter build web
firebase deploy --only hosting
```

---

## ✅ Verification Checklist

### Mobile App:
- [ ] Identity Toolkit API enabled (for web, but good to have)
- [ ] SHA-1 fingerprint added to Firebase Console
- [ ] SHA-256 fingerprint added to Firebase Console
- [ ] Latest google-services.json downloaded and replaced
- [ ] Phone Authentication enabled in Firebase Console
- [ ] App rebuilt with `flutter build apk`

### Web App:
- [ ] Identity Toolkit API enabled ← **CRITICAL**
- [ ] Domain verification enabled on reCAPTCHA site keys ← **CRITICAL**
- [ ] All domains added to Authorized domains
- [ ] Phone Authentication enabled
- [ ] Web app rebuilt and deployed

---

## 🧪 Testing

### Test Mobile:
1. Install the rebuilt APK
2. Open app → Try phone login
3. Enter phone number → Click "Send OTP"
4. **Should NOT see**: "Firebase Authentication authorization error"
5. **Should see**: OTP sent successfully

### Test Web:
1. Open: https://sonarcommunity.com
2. Open Chrome DevTools (F12) → Console
3. Try phone login
4. **Should NOT see**: "Failed to initialize reCAPTCHA Enterprise config"
5. **Should NOT see**: "400 Bad Request" errors
6. **Should see**: OTP sent successfully

---

## 🔍 Troubleshooting

### Mobile Still Shows Authorization Error:

1. **Verify SHA keys are added**:
   - Firebase Console → Project Settings → Android app → SHA fingerprints
   - Should see both SHA-1 and SHA-256 listed

2. **Verify google-services.json**:
   - Check `android/app/google-services.json` exists
   - Verify package name: `com.santnarhari.sant_narhari_sonar`
   - Download fresh copy from Firebase Console

3. **Rebuild app**:
   - `flutter clean`
   - `flutter build apk --release`

### Web Still Shows reCAPTCHA Errors:

1. **Verify Identity Toolkit API**:
   - Google Cloud Console → APIs & Services → Enabled APIs
   - Should see "Identity Toolkit API" with status "Enabled"

2. **Verify Domain Verification**:
   - Firebase Console → Authentication → Settings → reCAPTCHA
   - Site keys should show "Protected" (not "Incomplete")
   - Domain verification should be "Enabled"

3. **Check Browser Console**:
   - Look for specific error messages
   - Clear browser cache and try again

4. **Redeploy**:
   - `flutter build web`
   - `firebase deploy --only hosting`

---

## 📝 Summary

**Code Changes**: ✅ Already done
- Firebase JS SDK updated to 11.1.0
- reCAPTCHA container configured
- Error handling improved

**Firebase Console Actions Required**:
1. ✅ Enable Identity Toolkit API (Google Cloud Console)
2. ✅ Add SHA keys (Firebase Console)
3. ✅ Enable domain verification on reCAPTCHA keys (Firebase Console)
4. ✅ Verify authorized domains (Firebase Console)
5. ✅ Download latest google-services.json (Firebase Console)

**After All Steps**:
- Rebuild mobile app
- Rebuild and deploy web app
- Test both platforms

---

## 🚀 Quick Links

- **Enable Identity Toolkit API**: https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=sant-narhari-sonar
- **Firebase Console**: https://console.firebase.google.com/project/sant-narhari-sonar
- **Google Cloud Console**: https://console.cloud.google.com/apis/dashboard?project=sant-narhari-sonar

**Do ALL steps above, then rebuild and test!** 🎯
