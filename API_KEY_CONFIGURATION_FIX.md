# API Key Configuration - Fix Required

## ✅ What's Correct

1. **Identity Toolkit API** is selected ✅ - Perfect!
2. **Website restrictions** include most domains ✅
3. **API restriction** is set correctly ✅

## ⚠️ Issues to Fix

### Issue 1: Missing Wildcard on `sonarcommunity.co`

**Current**: `https://sonarcommunity.co`  
**Should be**: `https://sonarcommunity.co/*`

**Why**: The wildcard (`/*`) allows all paths on that domain. Without it, only the root path works.

### Issue 2: Incomplete Entry for `sant-narhari-sonar.web.app`

**Current**: `sant-narhari-sonar.web.app` (missing `https://`)  
**Should be**: `https://sant-narhari-sonar.web.app/*`

**Why**: Missing protocol (`https://`) and wildcard. This entry won't work as-is.

## ✅ Correct Website Restrictions List

Your website restrictions should be:

```
http://localhost:*
https://sant-narhari-sonar.firebaseapp.com/*
https://sant-narhari-sonar.web.app/*
https://sonarcommunity.com/*
https://www.sonarcommunity.com/*
https://sonarcommunity.co/*  ← Add wildcard
```

**Note**: You can remove `https://sant-narhari-sonar.firebaseapp.com/` (without wildcard) since `https://sant-narhari-sonar.firebaseapp.com/*` covers it.

## 🔧 How to Fix

1. In Google Cloud Console → **APIs & Services** → **Credentials**
2. Click on your API key (the one showing Identity Toolkit API)
3. Under **"Website restrictions"**:
   - **Edit** `https://sonarcommunity.co` → Change to `https://sonarcommunity.co/*`
   - **Edit** `sant-narhari-sonar.web.app` → Change to `https://sant-narhari-sonar.web.app/*`
   - **Remove** `https://sant-narhari-sonar.firebaseapp.com/` (keep only the one with `/*`)
4. Click **"Save"**
5. Wait 1-2 minutes for changes to take effect

## ✅ API Restrictions

**Current**: "Restrict key" with "Identity Toolkit API" ✅

**This is CORRECT** for Firebase Authentication. However, if you're also using:
- **Firestore** → You might need "Cloud Firestore API"
- **Storage** → You might need "Cloud Storage API"
- **Cloud Messaging** → You might need "Firebase Cloud Messaging API"

**For now, Identity Toolkit API alone is fine for OTP verification.**

## 📋 Final Checklist

- [x] Identity Toolkit API selected ✅
- [ ] Fix `sonarcommunity.co` → Add `/*` wildcard
- [ ] Fix `sant-narhari-sonar.web.app` → Add `https://` and `/*`
- [ ] Remove duplicate `sant-narhari-sonar.firebaseapp.com/` (keep only `/*` version)
- [ ] Save changes
- [ ] Wait 2 minutes
- [ ] Test web OTP verification

## 🧪 After Fixing

1. **Save** the API key configuration
2. Wait 2-3 minutes for changes to propagate
3. Clear browser cache
4. Test web OTP verification on https://sonarcommunity.com
5. Check browser console for errors

---

**Summary**: Your configuration is 95% correct! Just fix those 2 website entries and you're good to go! 🎯
