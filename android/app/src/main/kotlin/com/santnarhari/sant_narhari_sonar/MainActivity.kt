package com.santnarhari.sant_narhari_sonar

import android.content.pm.ApplicationInfo
import io.flutter.embedding.android.FlutterActivity
import com.google.firebase.auth.FirebaseAuth

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        // On emulator/debug, Play Integrity often fails. Disable app verification for testing
        // so Phone Auth works with test phone numbers (Firebase Console > Auth > Phone > Test numbers).
        val isDebuggable = (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        if (isDebuggable) {
            FirebaseAuth.getInstance().firebaseAuthSettings.setAppVerificationDisabledForTesting(true)
        }
    }
}
