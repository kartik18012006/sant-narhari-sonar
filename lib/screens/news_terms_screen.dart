import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'create_news_screen.dart';

/// News Section Terms & Conditions — must accept before news registration form.
/// Shown after payment, before CreateNewsScreen.
class NewsTermsScreen extends StatefulWidget {
  const NewsTermsScreen({super.key});

  @override
  State<NewsTermsScreen> createState() => _NewsTermsScreenState();
}

class _NewsTermsScreenState extends State<NewsTermsScreen> {
  bool _agreed = false;

  static const String _titleEn = 'News Section – Terms & Conditions';
  static const String _titleMr = 'न्यूज सेक्शन – नियम व अटी';

  static const String _bodyMr = r'''
१. न्यूजचा उद्देश
या अॅपमधील न्यूज सेक्शनचा उद्देश समाजहित, माहिती प्रसार, अपडेट्स व जनजागृती करणे हा आहे. कोणत्याही प्रकारची अफवा, दिशाभूल किंवा द्वेष पसरवणारी माहिती देणे प्रतिबंधित आहे.

२. न्यूज कंटेंटसाठी नियम
वापरकर्त्याने पोस्ट केलेली न्यूज:
सत्य, अचूक व पडताळलेली असावी
समाज, व्यक्ती किंवा संस्थेची बदनामी करणारी नसावी
धार्मिक, जातीय, राजकीय द्वेष निर्माण करणारी नसावी
अश्लील, हिंसक किंवा आक्षेपार्ह मजकूर असू नये
न्यायप्रविष्ट (Sub-judice) प्रकरणांबाबत चुकीची माहिती देऊ नये

३. वापरकर्त्याची जबाबदारी
न्यूज पोस्ट करणारा वापरकर्ता त्या न्यूजच्या सत्यतेस पूर्णपणे जबाबदार असेल
शक्य असल्यास न्यूजचा स्रोत (Source) नमूद करणे आवश्यक आहे
खोटी किंवा नियमबाह्य न्यूज पोस्ट केल्यास संबंधित पोस्ट काढून टाकली जाऊ शकते

४. अॅडमिन व अॅपची भूमिका (Disclaimer)
हे अॅप फक्त एक डिजिटल प्लॅटफॉर्म आहे
वापरकर्त्यांनी टाकलेल्या न्यूजच्या मजकुराची थेट जबाबदारी अॅप घेत नाही
नियमांचे उल्लंघन करणारी कोणतीही न्यूज कोणतीही पूर्वसूचना न देता काढून टाकण्याचा अधिकार अॅडमिनकडे राखीव आहे

५. जाहिरात व प्रायोजित न्यूज
Paid / Sponsored न्यूज असल्यास "प्रायोजित / जाहिरात" असा स्पष्ट उल्लेख करणे बंधनकारक आहे
जाहिरात न्यूज म्हणून फसवणूक करणारा मजकूर टाकण्यास मनाई आहे

६. कायदेशीर पालन
हा अॅप भारतातील लागू कायद्यांच्या अधीन आहे (IT Act 2000 इ.)
कायद्याचे उल्लंघन आढळल्यास संबंधित अधिकाऱ्यांना माहिती दिली जाऊ शकते

७. नियमांमध्ये बदल
अॅप प्रशासनाला नियम व अटी कधीही बदलण्याचा अधिकार राखीव आहे
बदललेले नियम अॅपमध्ये प्रकाशित केल्यानंतर सर्व वापरकर्त्यांवर लागू राहतील

८. संमती
अॅप वापरणे म्हणजे वापरकर्त्याने वरील सर्व नियम व अटी मान्य केल्या आहेत असे समजले जाईल.
''';

  static const String _bodyEn = r'''
1. Purpose of News
The News section of this app is intended for information sharing, community updates, and public awareness. Spreading rumors, misinformation, or hateful content is strictly prohibited.

2. News Content Guidelines
All news content must:
Be true, accurate, and verified
Not defame any individual, community, or organization
Not promote religious, caste-based, or political hatred
Not contain obscene, violent, or offensive material
Avoid misleading information on sub-judice matters

3. User Responsibility
The user posting news is solely responsible for its authenticity
Mentioning the source of news is recommended
False or policy-violating content may be removed without notice

4. Disclaimer
The app acts only as a digital platform
The app is not responsible for user-generated news content
The admin reserves the right to edit or remove any content that violates policies

5. Sponsored / Paid News
Sponsored or paid news must be clearly labeled as "Sponsored" or "Advertisement"
Misleading promotional content is strictly prohibited

6. Legal Compliance
This app operates under applicable Indian laws, including the IT Act, 2000
Legal authorities may be informed in case of violations

7. Policy Updates
The app reserves the right to modify these terms at any time
Updated terms will be effective once published in the app

8. Acceptance of Terms
By using the app, users agree to comply with all the above terms and conditions.
''';

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
          '$_titleEn / $_titleMr',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📜 $_titleEn',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '📰 मराठी आवृत्ती (Marathi Version)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _bodyMr,
                    style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '📰 English Version',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _bodyEn,
                    style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 24),
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
                              'I agree to the News Section Terms & Conditions / मी वरील नियम व अटी मान्य करतो',
                              style: TextStyle(
                                fontSize: 14,
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
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              height: AppTheme.buttonHeight,
              child: FilledButton(
                onPressed: _agreed
                    ? () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<bool>(
                            builder: (_) => const CreateNewsScreen(),
                          ),
                        );
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  ),
                ),
                child: const Text(
                  'Accept and Continue / मान्य करा आणि पुढे जा',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
