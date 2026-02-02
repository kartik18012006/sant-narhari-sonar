import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'email_login_screen.dart';
import 'main_shell_screen.dart';
import 'phone_otp_screen.dart';

/// Login / Sign Up — choose Phone or Email (APK-style: white screen, gold Skip, same padding).
class LoginSignupScreen extends StatelessWidget {
  const LoginSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.onboardingBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => _onSkip(context),
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppTheme.goldDark,
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
                'Choose how you want to continue',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 32),
              // Continue with Phone (Hidden on Web)
              if (!kIsWeb) ...[
                _AuthOptionCard(
                  icon: Icons.phone_android,
                  iconBgColor: AppTheme.phoneIconBg,
                  iconColor: AppTheme.phoneIcon,
                  title: 'Continue with Phone',
                  subtitle: "We'll send you an OTP via SMS",
                  onTap: () => _onContinueWithPhone(context),
                ),
                const SizedBox(height: 20),
                // OR
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              // Continue with Email
              _AuthOptionCard(
                icon: Icons.email_outlined,
                iconBgColor: AppTheme.emailIconBg,
                iconColor: AppTheme.emailIcon,
                title: 'Continue with Email',
                subtitle: 'Use your email and password',
                onTap: () => _onContinueWithEmail(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSkip(BuildContext context) {
    // Skip: go to main app (next), not back to first screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
      (route) => false,
    );
  }

  void _onContinueWithPhone(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PhoneOtpScreen()),
    );
  }

  void _onContinueWithEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
    );
  }
}

class _AuthOptionCard extends StatelessWidget {
  const _AuthOptionCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade500, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
