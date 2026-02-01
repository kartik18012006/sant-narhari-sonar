import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_theme.dart';
import 'firebase_options.dart';
import 'screens/main_shell_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/subscription_required_screen.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_service.dart';
import 'services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with proper error handling
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    // Log Firebase initialization errors for debugging
    debugPrint('Firebase initialization error: $e');
    // Continue anyway - Firebase might still work if config is correct
  }
  
  // Load saved language (English / Marathi) from SharedPreferences
  await LanguageService.instance.loadSavedLanguage();
  runApp(const SantNarhariSonarApp());
}

/// Rebuilds when LanguageService changes (English ↔ Marathi).
class SantNarhariSonarApp extends StatelessWidget {
  const SantNarhariSonarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Sant Narhari Sonar',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          locale: LanguageService.instance.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('mr'),
          ],
          home: _AuthGate(),
        );
      },
    );
  }
}

/// After signup: user must pay ₹21 (1-year subscription) to access main app.
/// Shows MainShell if signed in and has active subscription, else SubscriptionRequiredScreen or Onboarding.
class _AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }
        final user = snapshot.data;
        if (user == null) {
          return const OnboardingScreen();
        }
        return StreamBuilder<bool>(
          stream: FirestoreService.instance.subscriptionStatusStream(user.uid),
          builder: (context, subSnap) {
            if (subSnap.connectionState == ConnectionState.waiting) {
              return const _SplashScreen();
            }
            final hasSubscription = subSnap.data ?? false;
            if (hasSubscription) {
              return const MainShellScreen();
            }
            return const SubscriptionRequiredScreen();
          },
        );
      },
    );
  }
}

/// First screen shown on app launch (APK-style): logo, app name, gold loading.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.onboardingBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/app logo.png',
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(Icons.account_balance, color: AppTheme.gold, size: 48),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sant Narhari Sonar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
