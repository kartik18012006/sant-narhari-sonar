import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'login_signup_screen.dart';

/// Second screen: rules, eligibility, responsibilities, privacy (Marathi).
/// Shown after onboarding when user taps "Create Your Profile".
class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.onboardingBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header: app icon (left), Skip (right) — same as onboarding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAppIcon(),
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
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _sectionTitle(
                      'सोनार समाज एकत्रीकरणासाठी\nसामाजिक कार्यकर्ता / सदस्य नोंदणी नियम / व्यवसाय नोंदणी / व्यवसाय जाहिरात /',
                    ),
                    const SizedBox(height: 20),
                    _heading('१. उद्देश (Purpose)'),
                    _body(
                      'सोनार समाज सदस्य आणि सामाजिक कार्यकर्त्यांना जोडणे हा मुख्य उद्देश आहे. समाजातील कार्यक्रम, मदतकार्य, शिक्षण आणि एकात्मता वाढवणे हा मुख्य उद्देश.',
                    ),
                    const SizedBox(height: 16),
                    _heading('२. पात्रता (Eligibility)'),
                    _bullet('अर्जदार हा सोनार समाजाचा सदस्य असावा.'),
                    _bullet('वय १८ वर्षे किंवा त्यापेक्षा अधिक असावे.'),
                    _bullet('समाजसेवा, संघटन, शिक्षण किंवा समाजहिताच्या कामात रुची असावी.'),
                    _bullet('अर्जदाराचे वर्तणूक व सामाजिक चारित्र्य उत्तम असावे.'),
                    _bullet('कोणत्याही गुन्हेगारी / बेकायदेशीर कृतीत सहभाग नसावा.'),
                    const SizedBox(height: 16),
                    _heading('इतर तपशील (Other Details)'),
                    _bullet('ओळखपत्र (आधार / पॅन / मतदार ओळखपत्र)'),
                    const SizedBox(height: 16),
                    _heading('जबाबदाऱ्या (Responsibilities)'),
                    _subHeading('नोंदणीकृत सामाजिक कार्यकर्त्यांनी:'),
                    _bullet('समाजातील सदस्यांमध्ये एकता, सहकार्य आणि शांती राखावी.'),
                    _bullet('कोणत्याही वाद, गंधळे किंवा प्रचारातून दूर राहावे.'),
                    _bullet('समाजाच्या निधीचा पारदर्शक उपयोग सुनिश्चित करावा.'),
                    _bullet('समाजाच्या नियमांचे पालन करावे.'),
                    const SizedBox(height: 16),
                    _heading('गोपनीयता व नियम (Privacy and Rules)'),
                    _bullet('सदस्यांची वैयक्तिक माहिती गुप्त ठेवली जाईल.'),
                    _bullet(
                      'कोणतीही चुकीची किंवा बनावट माहिती दिल्यास सदस्यत्व रद्द केले जाईल.',
                    ),
                    _bullet(
                      'अॅपवर टाकलेले सर्व फोटो/ पोस्ट/ माहिती समाजाच्या मार्गदर्शक तत्त्वांनुसार असावी.',
                    ),
                    _bullet(
                      'कोणतेही धार्मिक, राजकीय किंवा अपमानास्पद विधान निषिद्ध आहे.',
                    ),
                    const SizedBox(height: 16),
                    _heading('मंजुरी प्रक्रिया (Approval Process)'),
                    _bullet(
                      'नोंदणी केल्यानंतर समाज समिती / प्रशासन अर्ज तपासेल.',
                    ),
                    _bullet(
                      'योग्य अर्जदारास मंजुरी देऊन \'सदस्य क्रमांक\' किंवा \'कार्यकर्ता आयडी\' दिला जाईल.',
                    ),
                    _bullet(
                      'अॅपमधील सुविधा (उदा. सूचना, कार्यक्रम माहिती, सेवा अर्ज) वापरण्याची परवानगी दिली जाईल.',
                    ),
                    const SizedBox(height: 16),
                    _heading('सदस्यत्व रद्द करण्याचे कारण (Reason for membership cancellation)'),
                    _bullet('चुकीची माहिती दिल्यास'),
                    _bullet('समाजविरोधी कृत्य किंवा गैरवर्तन'),
                    _bullet('समाजाच्या नियमांचे उल्लंघन'),
                    _bullet(
                      'निष्क्रियता (दीर्घकाळ अॅप वापर न करणे किंवा कार्यात सहभाग न देणे)',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: AppTheme.buttonHeight,
                child: FilledButton(
                  onPressed: () => _onContinue(context),
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
                      Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return Image.asset(
      'assets/app logo.png',
      width: 56,
      height: 56,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.gold.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.account_balance, color: AppTheme.gold, size: 26),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.person_outline, color: AppTheme.gold, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _heading(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _subHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _body(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade800,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4),
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSkip(BuildContext context) {
    // Skip: go to next screen (Login/Sign Up), not back to first
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginSignupScreen()),
    );
  }

  void _onContinue(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginSignupScreen()),
    );
  }
}
