import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'login_signup_screen.dart';
import 'main_shell_screen.dart';
import 'rules_screen.dart';

/// First content screen: onboarding / welcome (APK-style).
/// No AppBar — logo top-left, Skip top-right; two logos center; gold primary CTA, outline secondary.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/app logo.png'), context);
      precacheImage(const AssetImage('assets/main logo .png'), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.onboardingBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Top bar: logo (left), Skip (right) — same on every start screen
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AppIcon(assetPath: 'assets/app logo.png', color: AppTheme.gold),
                  TextButton(
                    onPressed: _onSkip,
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
              const SizedBox(height: 16),
              // Main content: single main logo on first screen
              Expanded(
                child: Center(
                  child: _AssetImage(
                    'assets/main logo .png',
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                    fallbackPath: 'assets/app logo.png',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Create Your Profile — primary CTA (gold)
              SizedBox(
                width: double.infinity,
                height: AppTheme.buttonHeight,
                child: FilledButton(
                  onPressed: _onCreateProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Create Your Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Already a member? Login — secondary (outline gold)
              SizedBox(
                width: double.infinity,
                height: AppTheme.buttonHeight,
                child: OutlinedButton(
                  onPressed: _onLogin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: AppTheme.gold, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      children: [
                        const TextSpan(text: 'Already a member? '),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            color: AppTheme.goldDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _onSkip() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
      (route) => false,
    );
  }

  void _onCreateProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RulesScreen()),
    );
  }

  void _onLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginSignupScreen()),
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.assetPath, required this.color});

  final String assetPath;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: 56,
      height: 56,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.account_balance, color: color, size: 26),
      ),
    );
  }
}

class _AssetImage extends StatelessWidget {
  const _AssetImage(
    this.assetPath, {
    this.width,
    this.height,
    required this.fit,
    this.fallbackPath,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? fallbackPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallbackPath != null
          ? Image.asset(
              fallbackPath!,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade600),
      );
}
