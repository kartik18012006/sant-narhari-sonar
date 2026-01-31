import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth wrapper: phone OTP, email/password, sign out, auth state.
class FirebaseAuthService {
  FirebaseAuthService._();
  static final FirebaseAuthService _instance = FirebaseAuthService._();
  static FirebaseAuthService get instance => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Send OTP to phone number. Use [onCodeSent] to show OTP input; use [onVerificationCompleted] when auto-sign-in (e.g. Android).
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onError,
    void Function(User user)? onVerificationCompleted,
  }) async {
    final fullNumber = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
    await _auth.verifyPhoneNumber(
      phoneNumber: fullNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final result = await _auth.signInWithCredential(credential);
        final user = result.user;
        if (user != null) onVerificationCompleted?.call(user);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? e.code);
      },
      codeSent: (String verId, int? resendToken) {
        onCodeSent(verId);
      },
      codeAutoRetrievalTimeout: (String verId) {},
      timeout: const Duration(seconds: 120),
    );
  }

  /// Sign in with OTP using verificationId and 6-digit code.
  Future<UserCredential?> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _auth.signInWithCredential(credential);
    return result;
  }

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Create account with email and password.
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Send email verification link to current user. Call after sign-up.
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Reload current user (e.g. after they verify email in another tab).
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
