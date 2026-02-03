# Build and Deployment Commands

## Prerequisites
- Flutter SDK installed and configured
- Git repository initialized
- Vercel account configured for web deployment
- Android signing keys configured (for app build)

---

## 1. Build Web App (for Vercel)

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build web app
flutter build web --release

# The build output will be in: build/web/
```

**Deploy to Vercel:**
```bash
# Option 1: Using Vercel CLI (if installed)
cd build/web
vercel --prod

# Option 2: Push to Git (if Vercel is connected to your repo)
git add build/web
git commit -m "Build web app with latest changes"
git push origin main

# Vercel will automatically deploy from the connected branch
```

---

## 2. Build Android App (APK)

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build APK (debug - for testing)
flutter build apk --debug

# Build APK (release - for production)
flutter build apk --release

# Build App Bundle (AAB - for Play Store)
flutter build appbundle --release

# Output locations:
# - APK: build/app/outputs/flutter-apk/app-release.apk
# - AAB: build/app/outputs/bundle/release/app-release.aab
```

---

## 3. Build iOS App (if needed)

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build iOS app
flutter build ios --release

# Note: iOS builds require Xcode and macOS
```

---

## 4. Complete Build and Push Workflow

### For Web (Vercel):
```bash
# 1. Clean and build
flutter clean
flutter pub get
flutter build web --release

# 2. Commit and push (if Vercel auto-deploys from Git)
git add .
git commit -m "Update: Remove Other payment option, fix admin access, individual matrimony payments"
git push origin main

# 3. Or deploy directly via Vercel CLI
cd build/web
vercel --prod
```

### For Android App:
```bash
# 1. Clean and build
flutter clean
flutter pub get
flutter build apk --release

# 2. Commit changes
git add .
git commit -m "Update: Remove Other payment option, fix admin access, individual matrimony payments"
git push origin main

# 3. APK will be available at: build/app/outputs/flutter-apk/app-release.apk
```

---

## 5. Verify Changes Before Building

Run these commands to verify everything works:

```bash
# Analyze code
flutter analyze

# Run tests (if any)
flutter test

# Check for issues
flutter doctor
```

---

## 6. Quick Build Scripts

### Web Build Script (save as `build_web.sh`):
```bash
#!/bin/bash
flutter clean
flutter pub get
flutter build web --release
echo "Web build complete! Output: build/web/"
```

### Android Build Script (save as `build_android.sh`):
```bash
#!/bin/bash
flutter clean
flutter pub get
flutter build apk --release
echo "Android build complete! APK: build/app/outputs/flutter-apk/app-release.apk"
```

Make scripts executable:
```bash
chmod +x build_web.sh build_android.sh
```

---

## Notes

- **Web builds** are automatically deployed to Vercel if connected to your Git repo
- **Android APK** can be installed directly on devices or uploaded to Play Store
- **Always test** the build locally before deploying to production
- **Firebase config** should be properly set for both web and mobile
