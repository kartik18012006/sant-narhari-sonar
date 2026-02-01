import 'package:firebase_auth/firebase_auth.dart';

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
      // Firebase handles reCAPTCHA automatically on web
      // For web, reCAPTCHA will be shown automatically by Firebase
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
          // Handle reCAPTCHA errors gracefully
          String errorMessage = e.message ?? e.code;
          if (e.code == 'missing-recaptcha-token' || e.code.contains('recaptcha')) {
            errorMessage = 'reCAPTCHA verification required. Please enable reCAPTCHA in Firebase Console (Authentication → Settings → reCAPTCHA Enterprise) or try again.';
          }
          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('recaptcha') || errorMessage.contains('RECAPTCHA')) {
        errorMessage = 'reCAPTCHA verification required. Please enable reCAPTCHA Enterprise in Firebase Console (Authentication → Settings → reCAPTCHA Enterprise) or contact support.';
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
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // =====================
  // SIGN OUT
  // =====================

  Future<void> signOut() async {
    await _auth.signOut();
  }
}