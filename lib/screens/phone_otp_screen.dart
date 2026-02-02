import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/msg91_service.dart';
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

  bool _loading = false;
  bool _otpSent = false;
  String? _phoneNumber; // Store full phone number with country code

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                _phoneNumber = null;
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
          child: Column(
            children: [
              Expanded(
                child: _otpSent ? _buildOtpInput() : _buildPhoneInput(),
              ),
            ],
          ),
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
          'We sent a 4-digit code to +91 ${_phoneController.text.trim()}',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          enabled: !_loading,
          maxLength: 4,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: InputDecoration(
            hintText: 'Enter 4-digit OTP',
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
      // Format: 91XXXXXXXXXX (country code + 10 digits, no +)
      final fullPhoneNumber = '91$number';
      _phoneNumber = fullPhoneNumber;

      final response = await Msg91Service.instance.sendOtp(fullPhoneNumber);
      
      if (!mounted) return;

      if (response['success'] == true || response['type'] == 'success') {
        setState(() {
          _otpSent = true;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent. Check your SMS.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _loading = false);
        final errorMsg = response['message'] ?? response['error'] ?? 'Failed to send OTP';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyPhoneError(errorMsg)),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyPhoneError(e.toString()))),
      );
    }
  }
  String _friendlyPhoneError(String message) {
    // Handle MSG91 specific errors
    if (message.toLowerCase().contains('invalid') && message.toLowerCase().contains('phone')) {
      return 'Invalid phone number. Use a valid 10-digit Indian mobile number (e.g. 9876543210).';
    }
    if (message.toLowerCase().contains('quota') || message.toLowerCase().contains('exceeded')) {
      return 'SMS quota exceeded. Please try again later or contact support.';
    }
    if (message.toLowerCase().contains('too many') || message.toLowerCase().contains('rate limit')) {
      return 'Too many attempts. Please wait a few minutes before trying again.';
    }
    
    // Handle Firebase errors
    if (message.contains('email-already-in-use')) {
      return 'An account with this phone number already exists.';
    }
    if (message.contains('weak-password')) {
      return 'Account creation failed. Please try again.';
    }
    if (message.contains('user-not-found') || message.contains('wrong-password')) {
      return 'Authentication failed. Please try again.';
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
    final code = _otpController.text.trim();
    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 4-digit OTP')),
      );
      return;
    }
    if (_phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please request OTP again.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      // Verify OTP with MSG91
      final verifyResponse = await Msg91Service.instance.verifyOtp(_phoneNumber!, code);
      
      if (!mounted) return;

      if (verifyResponse['success'] != true && verifyResponse['type'] != 'success') {
        final errorMsg = verifyResponse['message'] ?? verifyResponse['error'] ?? 'Invalid OTP code';
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg.contains('Invalid') || errorMsg.contains('invalid') 
                ? 'Invalid OTP code. Please check the code and try again.'
                : errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // MSG91 OTP verified successfully, now authenticate with Firebase
      // Generate email from phone number: phone_919999999999@santnarhari.com
      final email = 'phone_$_phoneNumber@santnarhari.com';
      // Use a default password (users won't need to know it since they use OTP)
      final password = '${_phoneNumber}_default_pass_2024';

      UserCredential? cred;
      try {
        // Try to sign in first (user might already exist)
        cred = await FirebaseAuthService.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          // User doesn't exist or password changed, create new account
          try {
            cred = await FirebaseAuthService.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
          } catch (createError) {
            if (mounted) {
              setState(() => _loading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account creation failed: ${createError.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
            return;
          }
        } else {
          rethrow;
        }
      }

      if (cred.user != null && mounted) {
        final uid = cred.user!.uid;
        final phoneNumber = '+91${_phoneController.text.trim()}';
        final displayName = 'User ${_phoneController.text.trim()}';
        
        // Let auth token propagate to Firestore to avoid permission-denied on first write
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        
        try {
          await FirestoreService.instance.setUserProfile(
            uid: uid,
            email: email,
            phoneNumber: phoneNumber,
            displayName: displayName,
          );
        } on FirebaseException catch (e) {
          if (e.code == 'permission-denied' && mounted) {
            await Future.delayed(const Duration(milliseconds: 800));
            if (!mounted) return;
            await FirestoreService.instance.setUserProfile(
              uid: uid,
              email: email,
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
          const SnackBar(content: Text('Authentication failed. Please try again.')),
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
