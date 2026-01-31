import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Terms and Conditions: Terms of Use, Advertisement, Business, Event terms.
/// Matches APK structure (Advertisement Terms & Conditions, Business Registration Terms, Event Terms).
class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Terms & Conditions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              title: 'Terms of Use',
              body: '''1. By using Sant Narhari Sonar app, you agree to these terms.
2. The app is for the Sonar Samaj community. Use it respectfully and in line with community guidelines.
3. Users must click on "I agree to the Terms & Privacy Policy" before registering.
4. The App Admin reserves the right to make changes, approve members, and send notifications.
5. If phrases like "Terms and Conditions Apply" or "Limited Offer" are used, the details must be easily accessible.''',
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Advertisement Terms & Conditions',
              body: '''By posting advertisements, you agree that content is appropriate and relevant to the Sonar community. The admin may remove or edit content that violates guidelines.''',
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Business Registration Terms & Conditions',
              body: '''After registration, the community committee/administration will review the application. Business listings must be genuine. The Admin has the right to request KYC documents (e.g., Caste Certificate, Aadhaar Card, etc.) to verify membership.''',
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Event Terms & Conditions',
              body: '''Events may be removed if they violate community guidelines or terms of service. By posting events, you agree they are relevant to the Sonar community.''',
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'News',
              body: '''By posting news, you agree to the following terms. News must be relevant to the Sonar community and comply with community guidelines. All news submissions are subject to admin review before being published. The app admin reserves the right to approve, reject, or remove any news post without prior notice.''',
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Matrimonial',
              body: '''Creating a fake profile or using someone else's photo/identity is prohibited. Fake, duplicate, or misleading profiles will be permanently blocked. You can search bride/groom profiles only after you have registered and completed the registration payment. Your registration may be pending admin approval; you will be notified when approved.''',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5),
          ),
        ],
      ),
    );
  }
}
