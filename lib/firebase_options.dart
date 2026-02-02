// Firebase config for web. Same project as mobile: sant-narhari-sonar
//
// WEB: Add a web app in Firebase Console (Project: sant-narhari-sonar)
//      then replace the placeholder values below with your config.
//      Or run: dart pub global activate flutterfire_cli && flutterfire configure
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase options for web. Mobile uses google-services.json / GoogleService-Info.plist.
class DefaultFirebaseOptions {
  /// Web config for project: sant-narhari-sonar
  /// Replace placeholders with values from Firebase Console → Project Settings → Your apps → Web app.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA66p2GptE2Qz9vFi40VAkNYOxoaHO8GwA',
    appId: '1:732075543745:web:792b383a28ce6795d75840',
    messagingSenderId: '732075543745',
    projectId: 'sant-narhari-sonar',
    authDomain: 'sant-narhari-sonar.firebaseapp.com',
    storageBucket: 'sant-narhari-sonar.firebasestorage.app',
    measurementId: 'G-E5Y9SH2GRN',
  );
}
