import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firebase Auth wrapper: phone OTP, email/password, sign out, auth state.
class FirebaseAuthService {
  FirebaseAuthService._();

  static final FirebaseAuthService _instance = FirebaseAuthService._();
  static FirebaseAuthService get instance => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  ConfirmationResult? _confirmationResult;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Send OTP to phone number
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    final fullNumber =
        phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';

    try {
      if (kIsWeb) {
        // ✅ REQUIRED for Flutter Web
        _confirmationResult =
            await _auth.signInWithPhoneNumber(fullNumber);

        // Web does not use verificationId
        onCodeSent('web');
      } else {
        // ✅ Android / iOS
        await _auth.verifyPhoneNumber(
          phoneNumber: fullNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            onError(e.message ?? e.code);
          },
          codeSent: (String verId, int? resendToken) {
            onCodeSent(verId);
          },
          codeAutoRetrievalTimeout: (_) {},
          timeout: const Duration(seconds: 120),
        );
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Verify OTP and sign in
  Future<UserCredential?> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      if (kIsWeb) {
        if (_confirmationResult == null) {
          throw Exception('OTP session expired. Please retry.');
        }
        return await _confirmationResult!.confirm(smsCode);
      } else {
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Email & password sign-in
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Create account with email & password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Reload user
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}