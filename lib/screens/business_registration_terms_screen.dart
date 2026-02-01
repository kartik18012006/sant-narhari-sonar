import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'business_registration_screen.dart';

/// Business Registration Terms & Conditions — must agree before registration form.
class BusinessRegistrationTermsScreen extends StatefulWidget {
  const BusinessRegistrationTermsScreen({super.key});

  @override
  State<BusinessRegistrationTermsScreen> createState() => _BusinessRegistrationTermsScreenState();
}

class _BusinessRegistrationTermsScreenState extends State<BusinessRegistrationTermsScreen> {
  bool _agreed = false;

  static const String _titleEn = 'Business Registration Terms & Conditions';
  static const String _titleMr = 'व्यवसाय नोंदणी नियम व अटी';

  static const String _bodyMr = r'''
👤 वापरकर्ता पात्रता
Business यूजर हा सोनार समाज्यातील कुठल्याही एका पोटजातीचा असावा.
नोंदणी करताना दिलेली माहिती खरी व अचूक असावी.
खोटी, पुनरावृत्ती केलेली किंवा दिशाभूल करणारी प्रोफाइल कायमची बंद केली जाईल.
टीप: दिलेली माहिती सत्यतेसाठी पडताळली केली जाईल.

🛡️ माहिती गोपनीयता आणि सुरक्षितता
सर्व वैयक्तिक माहिती सुरक्षितरीत्या साठवली जाईल आणि परवानगीशिवाय शेअर केली जाणार नाही.
वापरकर्त्याची माहिती केवळ पडताळणी, संवाद, आणि व्यवसाय विश्लेषणासाठी वापरली जाईल.

📈 व्यवसाय आचरण
अॅपचा वापर बेकायदेशीर, फसवे किंवा अनैतिक कामासाठी करू नये.
अॅपचा गैरवापर झाल्यास खाते बंद किंवा कायदेशीर कारवाई होऊ शकते.

💳 देयके आणि व्यवहार
अॅप विकासक/कंपनी वापरकर्त्यांमधील वादांसाठी जबाबदार राहणार नाही.

🚪 खाते बंद करण्याच्या अटी
नियमांचे उल्लंघन करणारे खाते कंपनी कोणतीही पूर्वसूचना न देता बंद करू शकते.
वापरकर्ता कधीही खाते हटविण्याची विनंती करू शकतो.

⚖️ कायदेशीर सूचना
सर्व कायदेशीर वाद स्थानिक न्यायालयांच्या अधिकारात येतील.
कंपनीला या अटी केव्हाही अद्ययावत करण्याचा अधिकार आहे.
''';

  static const String _bodyEn = r'''
👤 User Eligibility
Business user must be from one of the sub-castes of the Sonar community.
User must provide true and accurate information during registration.
Fake, duplicate, or misleading profiles will be permanently blocked.
Note: The provided information will be verified for authenticity.

🛡️ Data Privacy & Security
All personal data will be stored securely and will not be shared without consent.
User data may be used for verification, communication, and business analytics only.

📈 Business Conduct
Users shall not use the app for illegal, fraudulent, or unethical purposes.
Any misuse may result in account suspension or legal action.

💳 Payment & Transactions
App developer/company shall not be liable for disputes between users.

🚪 Termination of Account
The company reserves the right to suspend or delete any account violating rules.
User can request account deletion anytime.

⚖️ Legal & Disclaimer
All legal disputes shall be subject to jurisdiction of local courts.
The company reserves the right to update these Terms anytime.
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
                              'I agree to the Terms & Conditions / मी वरील नियम व अटी मान्य करतो',
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
                            builder: (_) => const BusinessRegistrationScreen(),
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
