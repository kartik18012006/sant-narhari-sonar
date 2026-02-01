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
    try {
      // For web, we need to specify the reCAPTCHA container
      if (kIsWeb) {
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: const Duration(seconds: 60),
          // Web-specific: specify reCAPTCHA container
          multiFactorSession: null,
          verificationCompleted: (PhoneAuthCredential credential) async {
            if (onVerificationCompleted != null) {
              final result = await _auth.signInWithCredential(credential);
              if (result.user != null) {
                onVerificationCompleted(result.user!);
              }
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            // Handle reCAPTCHA errors gracefully
            String errorMessage = e.message ?? e.code;
            if (e.code == 'missing-recaptcha-token' || 
                e.code == 'missing-recaptcha-response' ||
                e.code.contains('recaptcha') ||
                e.code.contains('RECAPTCHA')) {
              errorMessage = 'reCAPTCHA verification failed. Please ensure reCAPTCHA Enterprise is enabled in Firebase Console (Authentication → Settings → reCAPTCHA Enterprise) and try again.';
            } else if (e.code == 'invalid-phone-number') {
              errorMessage = 'Invalid phone number format. Please enter a valid phone number.';
            } else if (e.code == 'too-many-requests') {
              errorMessage = 'Too many requests. Please try again later.';
            } else if (e.code == 'quota-exceeded') {
              errorMessage = 'SMS quota exceeded. Please try again later.';
            }
            onError(errorMessage);
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      } else {
        // Mobile platforms (Android/iOS)
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            if (onVerificationCompleted != null) {
              final result = await _auth.signInWithCredential(credential);
              if (result.user != null) {
                onVerificationCompleted(result.user!);
              }
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            String errorMessage = e.message ?? e.code;
            if (e.code == 'invalid-phone-number') {
              errorMessage = 'Invalid phone number format. Please enter a valid phone number.';
            } else if (e.code == 'too-many-requests') {
              errorMessage = 'Too many requests. Please try again later.';
            } else if (e.code == 'quota-exceeded') {
              errorMessage = 'SMS quota exceeded. Please try again later.';
            } else if (e.code.contains('play_integrity') || e.code.contains('safety')) {
              errorMessage = 'Device verification issue. Ensure app is from Play Store or use test numbers in Firebase Console.';
            }
            onError(errorMessage);
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('recaptcha') || 
          errorMessage.contains('RECAPTCHA') ||
          errorMessage.contains('identitytoolkit')) {
        if (kIsWeb) {
          errorMessage = 'reCAPTCHA verification failed. Please ensure reCAPTCHA Enterprise is enabled in Firebase Console (Authentication → Settings → reCAPTCHA Enterprise) and try again.';
        } else {
          errorMessage = 'Phone verification failed. Please try again.';
        }
      }
      onError(errorMessage);
    }
  }

  Future<UserCredential?> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
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