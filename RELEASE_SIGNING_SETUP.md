# Release Signing Setup - Sant Narhari Sonar

Google Play requires your app to be **signed in release mode** (not debug mode). Follow these steps to fix the "signed in debug mode" error.

---

## Quick Setup (Choose One Method)

### Method 1: Interactive (Recommended)
Open Terminal and run:
```bash
cd "/Users/kartikkumar/Documents/sant narhari/Sant Narhari Sonar app"
./android/setup_release_signing.sh
```
When prompted, enter a **strong password** and remember it — you'll need it for every future app update!

### Method 2: Using Environment Variable
```bash
cd "/Users/kartikkumar/Documents/sant narhari/Sant Narhari Sonar app"
KEYSTORE_PASSWORD=your_secure_password ./android/setup_release_signing.sh
```
Replace `your_secure_password` with your chosen password.

---

## After Setup

1. **Build the app bundle:**
   ```bash
   flutter build appbundle
   ```

2. **Find your signed bundle:**
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```

3. **Upload to Play Console** — This new .aab will be accepted!

---

## Important: Backup Your Keystore

- The file `android/upload-keystore.jks` is your **release signing key**
- **Without it, you cannot update your app on Play Store** — Google will reject updates
- Copy it to a safe, secure location (encrypted cloud backup, external drive)
- Never share it publicly or commit it to git (it's already in .gitignore)

---

## If You Already Have a Keystore

If you have an existing release keystore, create `android/key.properties` manually:

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=upload-keystore.jks
```

Place your keystore file in the `android/` folder.
