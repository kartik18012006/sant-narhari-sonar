import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseAuthService {
  FirebaseAuthService._internal();
  static final FirebaseAuthService instance = FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =====================
  // COMMON GETTERS
  // =====================

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // =====================
  // PHONE AUTH
  // =====================

  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    void Function(User user)? onVerificationCompleted,
  }) async {
    // Block phone authentication on Web - only allow on mobile platforms
    if (kIsWeb) {
      onError('Phone authentication is not available on web. Please use email and password to sign in.');
      return;
    }

    try {
      // Verify Firebase is initialized by checking app name
      try {
        final appName = _auth.app.name;
        if (appName.isEmpty) {
          onError('Firebase not initialized. Please restart the app. If the problem persists, contact support.');
          return;
        }
      } catch (e) {
        onError('Firebase not initialized. Please restart the app. If the problem persists, contact support.');
        return;
      }

      // Mobile platforms (Android/iOS) only
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (onVerificationCompleted != null) {
            try {
              final result = await _auth.signInWithCredential(credential);
              if (result.user != null) {
                onVerificationCompleted(result.user!);
              }
            } catch (e) {
              // Auto-verification failed, continue with manual OTP
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = _getFriendlyErrorMessage(e, isWeb: false);
          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFriendlyErrorMessage(e, isWeb: false);
      onError(errorMessage);
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('not authorized') || 
          errorMessage.contains('unauthorized') ||
          errorMessage.contains('package name')) {
        errorMessage = 'Firebase Authentication authorization error. Please verify:\n1. Package name matches Firebase Console\n2. SHA-1/SHA-256 fingerprints are added in Firebase Console\n3. google-services.json is up to date\n\nContact support if the issue persists.';
      } else {
        errorMessage = 'Phone verification failed. Please try again.';
      }
      onError(errorMessage);
    }
  }

  String _getFriendlyErrorMessage(FirebaseAuthException e, {required bool isWeb}) {
    // Handle specific error codes
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format. Please enter a valid 10-digit Indian mobile number.';
      
      case 'too-many-requests':
        return 'Too many requests. Please wait a few minutes before trying again.';
      
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later or contact support.';
      
      case 'app-not-authorized':
      case 'unauthorized-domain':
        return 'This app is not authorized to use Firebase Authentication. Please verify:\n1. Package name matches Firebase Console (com.santnarhari.sant_narhari_sonar)\n2. SHA-1/SHA-256 fingerprints are added in Firebase Console\n3. google-services.json is up to date\n\nContact support if the issue persists.';
      
      case 'invalid-app-credential':
        return 'Invalid app credentials. Please verify Firebase configuration.';
      
      case 'missing-app-credential':
        return 'App credentials missing. Please verify Firebase configuration.';
      
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      
      case 'email-already-in-use':
        return 'An account already exists with this email. Please sign in instead.';
      
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      
      case 'invalid-email':
        return 'Invalid email address. Please enter a valid email.';
      
      default:
        // Check error message for common issues
        final message = e.message ?? e.code;
        if (message.contains('not authorized') || 
            message.contains('unauthorized') ||
            message.contains('package name') ||
            message.contains('app credential')) {
          return 'Firebase Authentication authorization error. Please verify:\n1. Package name matches Firebase Console\n2. SHA-1/SHA-256 fingerprints are added\n3. google-services.json is up to date\n\nContact support if the issue persists.';
        }
        if (message.contains('play_integrity') || message.contains('safety')) {
          return 'Device verification issue. Ensure app is from Play Store or use test numbers in Firebase Console.';
        }
        return message;
    }
  }

  Future<UserCredential?> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    // Block phone authentication on Web
    if (kIsWeb) {
      throw Exception('Phone authentication is not available on web. Please use email and password to sign in.');
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // Re-throw with better error message
      throw FirebaseAuthException(
        code: e.code,
        message: _getOtpVerificationErrorMessage(e),
      );
    } catch (e) {
      // Wrap other errors
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  String _getOtpVerificationErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check the code and try again.';
      case 'session-expired':
        return 'OTP session expired. Please request a new code.';
      case 'invalid-verification-id':
        return 'Invalid verification session. Please request a new OTP.';
      case 'code-expired':
        return 'OTP code has expired. Please request a new code.';
      default:
        return e.message ?? 'OTP verification failed. Please try again.';
    }
  }

  // =====================
  // EMAIL / PASSWORD
  // =====================

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }
    if (user.email == null || user.email!.isEmpty) {
      throw Exception('User does not have an email address');
    }
    if (user.emailVerified) {
      throw Exception('Email is already verified');
    }
    await user.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  /// Check if current user's email is verified
  bool get isEmailVerified {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  // =====================
  // SIGN OUT
  // =====================

  Future<void> signOut() async {
    await _auth.signOut();
  }
}