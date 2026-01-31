import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../payment_config.dart';
import '../services/language_service.dart';
import 'payment_screen.dart';

/// Shown after signup until user pays ₹21 (1-year subscription). Mandatory to access main app.
class SubscriptionRequiredScreen extends StatelessWidget {
  const SubscriptionRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.onboardingBackground,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Icon(Icons.lock_outline, size: 64, color: AppTheme.gold),
                  const SizedBox(height: 24),
                  Text(
                    lang.pick('App Access', 'अॅप प्रवेश'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lang.pick(
                      'Pay ₹21 for 1-year subscription to access the Sant Narhari Sonar app.',
                      'संत नरहरी सोनार अॅप वापरण्यासाठी १ वर्षाच्या सदस्यत्वासाठी ₹२१ भरा.',
                    ),
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: AppTheme.buttonHeight,
                    child: FilledButton(
                      onPressed: () async {
                        final paid = await Navigator.of(context).push<bool>(
                          MaterialPageRoute<bool>(
                            builder: (_) => PaymentScreen(
                              featureId: PaymentConfig.loginYearly,
                              amount: PaymentConfig.loginYearlyAmount,
                            ),
                          ),
                        );
                        if (paid == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(lang.pick('Payment successful. You now have full app access.', 'पेमेंट यशस्वी. आता तुम्हाला पूर्ण अॅप प्रवेश आहे.')),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                        ),
                      ),
                      child: Text(
                        '${lang.pick('Pay', 'पैसे द्या')} ${PaymentConfig.formattedAmount(PaymentConfig.loginYearlyAmount)} — ${lang.pick('1 Year', '१ वर्ष')}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
