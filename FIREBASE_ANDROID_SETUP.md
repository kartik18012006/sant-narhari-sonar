# Fix Firebase Auth "app not authorized" on Android

The error means Firebase does not recognize your app. Add your Android app’s **package name** and **SHA-1 / SHA-256** in the Firebase Console.

## 1. Open Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Open your project (the one used by this app)
3. Click the **gear icon** → **Project settings**
4. Scroll to **Your apps**

## 2. Use or add the Android app

- If you already have an Android app with this package, click it.
- If not, click **Add app** → **Android**, then:
  - **Android package name:** `com.santnarhari.sant_narhari_sonar`
  - (Optional) App nickname, e.g. "Sant Narhari Sonar"
  - Skip "Download config" for now if you already have `google-services.json`
  - Click **Register app**

## 3. Add SHA fingerprints

**⚠️ IMPORTANT**: SHA keys are NOT automatically integrated. You must manually add them to Firebase Console.

### Quick Method: Use the Helper Script

Run this command to get your SHA fingerprints:

```bash
cd android
./get_sha_keys.sh
```

This will show you:
- Debug keystore SHA-1 and SHA-256 (for testing/emulator)
- Release keystore SHA-1 and SHA-256 (for production, if configured)

### Manual Method: Get SHA Keys Manually

**For Debug Keystore** (testing/emulator):
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**For Release Keystore** (production):
```bash
keytool -list -v -keystore <path-to-your-release.keystore> -alias <your-alias>
```

### Add SHA Keys to Firebase Console

In **Project settings** → **Your apps** → your Android app:

1. Find the **SHA certificate fingerprints** section
2. Click **Add fingerprint**
3. Paste your **SHA-1** fingerprint
4. Click **Add fingerprint** again and paste your **SHA-256** fingerprint
5. **Important**: Add BOTH debug AND release SHA keys if you use both keystores
6. Save

**Note**: The SHA values shown in this file are examples. Always use the script or command above to get YOUR current SHA keys, as they may differ.

## 4. Deploy Firestore rules (fix permission-denied)

If you see **cloud_firestore/permission-denied** after entering OTP, your Firestore rules are not deployed or are too strict.

1. In Firebase Console go to **Build** → **Firestore Database** → **Rules**
2. Replace the rules with the contents of **firestore.rules** in this project (or deploy via CLI: `firebase deploy --only firestore:rules`)
3. Publish the rules

The project’s **firestore.rules** allow signed-in users to read/write their own document in `users/{userId}`.

## 5. Payment config (Firestore) — for Pay ₹21 / payment screen

The app reads payment gateway config from the **payment** collection in Firestore. It looks for a document (in this order): **razorpay**, **test**, or the **first document** in the collection.

Each document must have:

- **key_id** (or **keyId**): your Razorpay API key (from [Razorpay Dashboard](https://dashboard.razorpay.com/) → Settings → API Keys)
- **mode** (optional): `"test"` or `"live"` (defaults to `"test"`)
- **key_secret** (or **keySecret**): your Razorpay API secret — **required for UPI and Card/Net Banking**. Add this so the app can create orders and open Razorpay checkout. (Test only: never expose secret in production; use a Cloud Function to create orders instead.)

Example for UPI/Card: In **Firestore** → **payment** collection, add a document (e.g. **test** or **razorpay**) with fields:

- `key_id` = `rzp_test_xxxxxxxx` (Razorpay test key)
- `key_secret` = your Razorpay test secret
- `mode` = `test`

Without **key_secret**, only the **Other** payment method works (bank transfer). With **key_secret**, **UPI** and **Card / Net Banking** open Razorpay checkout.

After saving, the payment screen will load the config and the orange “Payment config not found” message will go away.

## 6. Enable Phone sign-in (if needed)

1. In Firebase Console go to **Build** → **Authentication** → **Sign-in method**
2. Enable **Phone**
3. Save

## 7. (Emulator / debug only) Add test phone numbers

The app disables Play Integrity in **debug** builds so Phone Auth works on the emulator. In that mode, **only test phone numbers** work (real numbers will not receive SMS).

1. In Firebase Console go to **Build** → **Authentication** → **Sign-in method**
2. Open **Phone** and expand **Phone numbers for testing**
3. Click **Add phone number**
4. Add your number (e.g. `+91 8448250988`) and a fixed verification code (e.g. `123456`)
5. Save

Use that same number and code in the app: enter the phone number, tap Continue, then enter the 6-digit code you set (e.g. `123456`).

## 8. Rebuild and run

- Stop the app completely and run again: `flutter run` or Run/Debug from your IDE
- Try login with the **test phone number** and the **verification code** you set in Firebase

---

**Note:** These SHA values are from your **debug** keystore (`~/.android/debug.keystore`). For release builds you must add the **release** keystore’s SHA-1 and SHA-256 the same way (get them with `keytool -list -v -keystore <your-release.keystore>`). In **release** builds, app verification is enabled and real phone numbers work; test numbers are only for debug/emulator.
