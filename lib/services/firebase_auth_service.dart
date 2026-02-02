import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseAuthService {
  FirebaseAuthService._internal();
  static final FirebaseAuthService instance = FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    void Function(User user)? onVerificationCompleted,
  }) async {
    if (kIsWeb) {
      onError('Phone authentication is not available on web. Please use email and password to sign in.');
      return;
    }

    try {
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
          onError(e.message ?? e.code);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? e.code);
    } catch (e) {
      onError('Phone verification failed. Please try again.');
    }
  }

  Future<UserCredential?> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
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
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'OTP verification failed. Please try again.',
      );
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

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

  Future<void> signOut() async {
    await _auth.signOut();
  }
}