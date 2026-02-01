import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'matrimony_registration_screen.dart';

/// Matrimony Terms & Conditions — must agree before registration form.
class MatrimonyTermsScreen extends StatefulWidget {
  final bool isGroom;
  const MatrimonyTermsScreen({super.key, required this.isGroom});

  @override
  State<MatrimonyTermsScreen> createState() => _MatrimonyTermsScreenState();
}

class _MatrimonyTermsScreenState extends State<MatrimonyTermsScreen> {
  bool _agreed = false;

  static const String _titleEn = 'Rules for Matrimony Registration';
  static const String _titleMr = 'विवाह नोंदणी साठी आवश्यक नियम';

  static const String _bodyMr = r'''
१. वापरकर्ता पात्रता
वापरकर्त्याचे वय 18 वर्षे (महिला) आणि 21 वर्षे (पुरुष) पूर्ण असावे.
वापरकर्त्याने आपल्या वैयक्तिक माहितीबाबत (नाव, जन्मतारीख, फोटो, पत्ता इ.) खरी माहिती द्यावी.
खोटी प्रोफाइल तयार करणे किंवा दुसऱ्याचा फोटो/ओळख वापरणे प्रतिबंधित आहे.

२. नोंदणी प्रक्रिया
प्रत्येक वापरकर्त्याने वैध ईमेल, मोबाईल नंबर, दिला आहे याची खात्री करावी.
प्रोफाइल माहिती (जसे की जात, धर्म, शिक्षण, व्यवसाय, पत्ता इ.) स्पष्टपणे द्यावी.
साइट मालकास चुकीची माहिती आढळल्यास प्रोफाइल काढून टाकण्याचा अधिकार राहील.

३. गोपनीयता धोरण 🔒
वापरकर्त्यांची वैयक्तिक माहिती कोणत्याही तृतीय पक्षाला (third party) विकली किंवा शेअर केली जाणार नाही.
वापरकर्त्यांचे फोटो, संपर्क माहिती फक्त लॉगिन केलेल्या व ओळख पुष्टी झालेल्या सदस्यांनाच दिसेल.

४. वापर अटी
वापरकर्त्याने कोणत्याही प्रकारचे अपमानास्पद, अश्लील, किंवा बेकायदेशीर कंटेंट टाकू नये.
साइटचा वापर फक्त वैवाहिक जोडीदार शोधण्यासाठीच करावा.
बेकायदेशीर व्यवहार, फसवणूक किंवा प्रचारासाठी वापरल्यास खाते तत्काळ बंद केले जाईल.

५. जबाबदारी ⚖️
साइट फक्त माध्यम आहे — ती जोडीदार निवडीची हमी देत नाही.
वापरकर्त्यांमधील संवादावर साइट मालक जबाबदार राहणार नाही.
वापरकर्त्यांनी स्वतःची काळजी व पडताळणी करावी (self-verification).

६. पेमेंट व सदस्यता 💳
पेमेंट नॉन रिफंड असेल.
भरलेल्या फॉर्मची वैधता १ वर्ष असेल.

७. खाते रद्द व निलंबन 🚪
चुकीची माहिती, गैरवर्तन, किंवा नियमभंग झाल्यास खाते निलंबित करता येईल.
वापरकर्त्याला स्वेच्छेने खाते बंद करण्याचा अधिकार असेल.
''';

  static const String _bodyEn = r'''
1. User Eligibility
The user's age must be at least 18 years (for females) and 21 years (for males).
The user must provide true information regarding their personal details (name, date of birth, photo, address, etc.).
Creating a fake profile or using someone else's photo/identity is prohibited.

2. Registration Process
Every user must ensure they provide a valid email and mobile number.
Profile information (such as caste, religion, education, occupation, address, etc.) must be provided clearly.
The site owner reserves the right to remove a profile if incorrect information is found.

3. Privacy Policy 🔒
Users' personal information will not be sold or shared with any third party.
Users' photos and contact information will only be visible to logged-in and verified members.

4. Terms of Use
Users must not post any defamatory, obscene, or illegal content.
The site should only be used for the purpose of finding a matrimonial match.
The account will be terminated immediately if used for illegal transactions, fraud, or promotion.

5. Disclaimer & Limitation of Liability ⚖️
The site is only a medium—it does not guarantee partner selection.
The site owner will not be responsible for communication between users.
Users should take care and perform their own verification (self-verification).

6. Payment & Subscription Rules 💳
Payments will be non-refundable.
The validity of the filled form will be for 1 year.

7. Account Termination 🚪
The account may be suspended for incorrect information, misconduct, or violation of rules.
The user has the right to voluntarily close their account.
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
                              'I agree to the Terms & Privacy Policy / मी वरील नियम व अटी मान्य करतो',
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
                            builder: (_) => MatrimonyRegistrationScreen(isGroom: widget.isGroom),
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
                  'Accept & Continue / मान्य करा आणि पुढे जा',
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
