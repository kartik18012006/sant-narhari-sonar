import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'register_social_worker_screen.dart';

/// Social Worker Terms & Conditions — must agree before registration form.
class SocialWorkerTermsScreen extends StatefulWidget {
  const SocialWorkerTermsScreen({super.key});

  @override
  State<SocialWorkerTermsScreen> createState() => _SocialWorkerTermsScreenState();
}

class _SocialWorkerTermsScreenState extends State<SocialWorkerTermsScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Social Worker Terms & Conditions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'सामाजिक कार्यकर्ता नियम व अटी',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            _sectionHeading('Registration'),
            _bullet('Experience: A social worker must have a minimum of 3 to 5 years of experience in this field.'),
            _bullet('Accuracy: All information provided by the user must be true, accurate, and up-to-date. Providing incorrect information may lead to account termination.'),
            _bullet('Code of Conduct: Users are strictly prohibited from posting advertisements or news related to any political party while the code of conduct is in effect.'),
            _bullet('Inappropriate Content: Posting any defamatory, religious, political, or obscene content is strictly forbidden.'),
            _bullet('Social Harmony: Avoid posts that create social discord or hurt the sentiments of others.'),
            _bullet('Fraud: Spreading any form of fraud or misinformation is prohibited.'),
            const SizedBox(height: 28),
            // Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                    activeColor: AppTheme.gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        'I agree to the Terms & Conditions',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Accept & Continue
            SizedBox(
              width: double.infinity,
              height: AppTheme.buttonHeight,
              child: FilledButton(
                onPressed: _agreed ? _onAccept : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  ),
                ),
                child: const Text(
                  'Accept & Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  void _onAccept() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RegisterSocialWorkerScreen(),
      ),
    );
  }
}
