import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import 'main_shell_screen.dart';

/// Screen shown when user taps "Continue with Phone" — enter phone, Send OTP, then enter OTP and verify.
class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  String? _verificationId;
  bool _loading = false;
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: AppTheme.onboardingBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_disabled, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 24),
                  const Text(
                    'Phone Authentication Not Available',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Phone OTP authentication is not available on web. Please use email and password to sign in.',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppTheme.onboardingBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (_otpSent) {
              setState(() {
                _otpSent = false;
                _verificationId = null;
                _otpController.clear();
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: _loading ? null : _onSkip,
            child: Text(
              'Skip',
              style: TextStyle(
                color: _loading ? Colors.grey : AppTheme.goldDark,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _otpSent ? _buildOtpInput() : _buildPhoneInput(),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Login / Sign Up',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your phone number to continue',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 8),
          Text(
            'Debug: use a test phone number from Firebase Console (Auth → Phone → Test numbers).',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.phone_android, size: 22, color: Colors.grey.shade600),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.phone,
                          enabled: !_loading,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Enter phone number',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                              borderSide: const BorderSide(color: AppTheme.gold, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.emailIconBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppTheme.emailIcon, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "We'll send you a verification code via SMS",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.emailIcon,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: AppTheme.buttonHeight,
          child: FilledButton(
            onPressed: _loading ? null : _onSendOtp,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Send OTP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Enter OTP',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit code to +91 ${_phoneController.text.trim()}',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          enabled: !_loading,
          maxLength: 6,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(
            hintText: 'Enter 6-digit OTP',
            counterText: '',
            prefixIcon: Icon(Icons.sms_outlined, color: AppTheme.gold, size: 22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: const BorderSide(color: AppTheme.gold, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _loading ? null : _onResendOtp,
            child: Text(
              "Didn't receive code? Resend",
              style: TextStyle(fontSize: 14, color: _loading ? Colors.grey : AppTheme.goldDark),
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: AppTheme.buttonHeight,
          child: FilledButton(
            onPressed: _loading ? null : _onVerifyOtp,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Verify & Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _onSkip() {
    // Skip: go to main app (next), not back to first screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
      (route) => false,
    );
  }

  Future<void> _onSendOtp() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone authentication is not available on web. Please use email and password.'),
        ),
      );
      return;
    }

    final number = _phoneController.text.trim().replaceAll(RegExp(r'\s'), '');

    if (number.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(number)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid 10-digit Indian mobile number (e.g. 9876543210)',
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuthService.instance.sendPhoneOtp(
        phoneNumber: '+91$number',
        onCodeSent: (verificationId) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent. Check your SMS.'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onError: (message) {
          if (!mounted) return;
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_friendlyPhoneError(message))),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyPhoneError(e.toString()))),
      );
    }
  }
  String _friendlyPhoneError(String message) {
    // Handle authorization errors (most critical)
    if (message.contains('not authorized') || 
        message.contains('unauthorized') ||
        message.contains('package name') ||
        message.contains('app credential') ||
        message.contains('app-not-authorized')) {
      return 'Firebase Authentication authorization error.\n\nPlease verify:\n• Package name matches Firebase Console\n• SHA-1/SHA-256 fingerprints are added\n• google-services.json is up to date\n\nContact support if the issue persists.';
    }
    
    
    // Handle other common errors
    if (message.contains('invalid-phone-number') || message.contains('Invalid')) {
      return 'Invalid phone number. Use a valid 10-digit Indian mobile number (e.g. 9876543210).';
    }
    if (message.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a few minutes before trying again.';
    }
    if (message.contains('quota') || message.contains('exceeded')) {
      return 'SMS quota exceeded. Please try again later or contact support.';
    }
    if (message.contains('play_integrity') || message.contains('safety')) {
      return 'Device verification issue. Ensure app is from Play Store or use test numbers in Firebase Console.';
    }
    if (message.contains('Firebase not initialized')) {
      return 'Firebase initialization error. Please restart the app.';
    }
    
    // Return message (truncate if too long)
    return message.length > 150 ? message.substring(0, 150) + '...' : message;
  }

  Future<void> _onResendOtp() async {
    if (_loading) return;
    _otpController.clear();
    await _onSendOtp();
  }

  Future<void> _onVerifyOtp() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone authentication is not available on web. Please use email and password.'),
        ),
      );
      return;
    }

    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }
    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please request OTP again.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuthService.instance.verifyOtpAndSignIn(
        verificationId: _verificationId!,
        smsCode: code,
      );
      if (cred?.user != null && mounted) {
        final uid = cred!.user!.uid;
        final phoneNumber = cred.user!.phoneNumber;
        final displayName = cred.user!.displayName ?? 'User';
        // Let auth token propagate to Firestore to avoid permission-denied on first write
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        try {
          await FirestoreService.instance.setUserProfile(
            uid: uid,
            phoneNumber: phoneNumber,
            displayName: displayName,
          );
        } on FirebaseException catch (e) {
          if (e.code == 'permission-denied' && mounted) {
            await Future.delayed(const Duration(milliseconds: 800));
            if (!mounted) return;
            await FirestoreService.instance.setUserProfile(
              uid: uid,
              phoneNumber: phoneNumber,
              displayName: displayName,
            );
          } else {
            rethrow;
          }
        }
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShellScreen()),
          (route) => false,
        );
      } else if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification failed. Please try again or request a new code.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        String message = 'OTP verification failed.';
        switch (e.code) {
          case 'invalid-verification-code':
            message = 'Invalid OTP code. Please check the code and try again.';
            break;
          case 'session-expired':
          case 'code-expired':
            message = 'OTP code has expired. Please tap Resend to get a new code.';
            break;
          case 'invalid-verification-id':
            message = 'Invalid verification session. Please request a new OTP.';
            break;
          default:
            message = e.message ?? e.code;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP verification failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
