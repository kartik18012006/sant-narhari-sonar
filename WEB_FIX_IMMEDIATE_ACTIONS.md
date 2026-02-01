# 🚨 IMMEDIATE ACTIONS TO FIX WEB RECAPTCHA

## ⚡ Quick Fix (5 minutes)

### Step 1: Enable Domain Verification (CRITICAL)

1. Go to **Firebase Console**: https://console.firebase.google.com/
2. Select project: **sant-narhari-sonar**
3. Go to: **Authentication** → **Settings** → **reCAPTCHA**
4. Under **"Configured platform site keys"**, find the Web key(s)
5. Click on the key that shows **"Domain verification disabled"**
6. Click **"Enable domain verification"** or **"Verify domains"**
7. Add these domains:
   - `sonarcommunity.com`
   - `www.sonarcommunity.com`
   - `localhost` (for development)
   - `sant-narhari-sonar.web.app`
   - `sant-narhari-sonar.firebaseapp.com`
8. **Save**

### Step 2: Enable Identity Toolkit API (CRITICAL)

**Important**: Firebase Authentication uses **"Identity Toolkit API"**, NOT "Firebase Authentication API"

1. Go to **Google Cloud Console**: https://console.cloud.google.com/
2. Select project: **sant-narhari-sonar**
3. Go to: **APIs & Services** → **Library**
4. Search for: **"Identity Toolkit API"**
5. Click on **"Identity Toolkit API"**
6. Click **"Enable"** button
7. Wait for it to enable (takes a few seconds)

**OR use direct link**: https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=sant-narhari-sonar

### Step 3: Verify API Key Restrictions

1. Go to: **APIs & Services** → **Credentials**
2. Find API key: `AIzaSyA66p2GptE2Qz9vFi40VAKNYOxoaH08GwA`
3. Click to edit
4. Under **"Application restrictions"**:
   - Select **"HTTP referrers (web sites)"**
   - Add:
     - `https://sonarcommunity.com/*`
     - `https://www.sonarcommunity.com/*`
     - `http://localhost:*`
     - `https://sant-narhari-sonar.web.app/*`
     - `https://sant-narhari-sonar.firebaseapp.com/*`
5. Under **"API restrictions"**:
   - Select **"Restrict key"**
   - Ensure **"Identity Toolkit API"** is in the list (if restricting)
   - Or select **"Don't restrict key"** for testing
6. **Save**

### Step 4: Rebuild and Deploy

```bash
cd "/Users/kartikkumar/Documents/sant narhari/Sant Narhari Sonar app"
flutter clean
flutter build web
firebase deploy --only hosting
```

### Step 5: Test

1. Open: https://sonarcommunity.com
2. Open Chrome DevTools (F12) → Console
3. Try phone login
4. **Should NOT see**: "Failed to initialize reCAPTCHA Enterprise config"
5. **Should see**: reCAPTCHA working without errors

## ✅ What I Fixed in Code

1. ✅ Updated Firebase JS SDK: `11.0.0` → `11.1.0`
2. ✅ Improved reCAPTCHA container (hidden but present)
3. ✅ Error handling already in place

## 🔴 What You Must Do

**The code is fixed, but you need to:**

1. **Enable Identity Toolkit API** in Google Cloud Console ← **CRITICAL**
2. **Enable domain verification** on reCAPTCHA site keys in Firebase Console ← **CRITICAL**
3. **Configure API key restrictions** properly
4. **Rebuild and redeploy** web app

## 📞 If Still Not Working

After completing the steps above, if errors persist:

1. Check Firebase Console → Authentication → Settings → reCAPTCHA
2. Verify site keys show **"Protected"** status (not "Incomplete")
3. Verify **"Assessment count"** increases after testing
4. Check browser console for specific error messages
5. Clear browser cache and try again

---

**The main issue is domain verification being disabled on your reCAPTCHA site keys. Enable it and the web verification will work!**
