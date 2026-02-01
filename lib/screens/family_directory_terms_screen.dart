import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'family_directory_registration_screen.dart';

/// Family Directory Terms & Conditions — must agree before registration form.
class FamilyDirectoryTermsScreen extends StatefulWidget {
  const FamilyDirectoryTermsScreen({super.key});

  @override
  State<FamilyDirectoryTermsScreen> createState() => _FamilyDirectoryTermsScreenState();
}

class _FamilyDirectoryTermsScreenState extends State<FamilyDirectoryTermsScreen> {
  bool _agreed = false;

  static const String _titleEn = 'Family Directory Terms & Conditions';
  static const String _titleMr = 'कुटुंब निर्देशिका नियम व अटी';

  static const String _bodyMr = r'''
१. पात्रता 👤
वापरकर्ता हा फक्त सोनार समाजाचा सदस्य असावा.
बाहेरील लोकांना नोंदणी करण्यास परवानगी नाही. फॉर्म भरल्यास तो फॉर्म सर्व बाजूनी तपासून फक्त एप प्रशासकाच्या मंजुरीनंतर ग्राह्य धरला जाईल नाहीतर काढून टाकण्याचे अधिकार एप संच्यालकला असतील.
वापरकर्त्याचे वय किमान १८ वर्षे असावे बंधनकारक आहे याची नोंद घ्यावी अन्यथा तो फॉर्म बाद करण्यात येईल.

२. नोंदणी प्रक्रिया (Registration Process) 📝
वापरकर्त्याने खालील माहिती अचूक व खरी भरावी.

३. ओळख व पडताळणी (Verification & Approval) ✅
एप संच्यालकला प्रत्येक नवीन नोंदणी Approve / Reject करण्याचा अधिकार असेल.
सदस्यत्वाची पडताळणी करण्यासाठी Admin ला KYC डॉक्युमेंट (उदा. जातीचा दाखला, आधार कार्ड, इ.) मागवण्याचा अधिकार असेल.

४. गोपनीयता व डेटा सुरक्षा (Privacy & Data Security) 🔒
वापरकर्त्याची माहिती ही फक्त फक्त समाजाच्या अंतर्गत वापरासाठी केली जाऊ शकते याचे अधिकार एप संच्यालकला असतील.
डेटा कोणत्याही तृतीय पक्षाला विकला / शेअर केला जाणार नाही.
आपला सर्व डेटा व्यवस्थित पाठवावा.

५. वापरकर्तासाठी वर्तन नियम व अटी 🚫
वापरकर्त्याने एप वर कोणतेही गैरवर्तन, अपमानास्पद पोस्ट, किंवा खोटी माहिती टाकू नये.
अशा उल्लंघनावर खाते डिलिट करण्याचा अधिकार एप संच्यालकला ला असेल.
कोणत्याही सार्वजनिक पोस्टमध्ये धार्मिक, राजकीय किंवा भडकाऊ मजकूर प्रतिबंधित असेल.

६. नियम व अटी 📄
नोंदणीपूर्वी वापरकर्त्याने "I agree to the Terms & Privacy Policy" वर क्लिक करणे आवश्यक.
त्या दस्तऐवजात डेटा वापर, जबाबदारी, आणि वर्तन नियम स्पष्ट असावेत.

७. एप संच्यालकला ला असणारे अधिकार 🛡️
एप संच्यालकला कोणत्याही वेळी वापरकर्ता खाते निलंबित / हटवू शकतो, जर तो नियम तोडतो.
एप संच्यालकला बदल, सदस्य मंजुरी, आणि सूचना पाठवण्याचे अधिकार असतील.
''';

  static const String _bodyEn = r'''
1. Eligibility 👤
User must be a member of the Sonar Samaj only.
Registration is not permitted for outsiders. Forms will be verified and accepted only after App Admin approval. The App Admin reserves the right to remove unauthorized users.
The user must be at least 18 years of age. This is mandatory; otherwise, the form will be rejected.

2. Registration Process 📝
The user must fill in the following information accurately and truthfully.

3. Verification & Approval ✅
The App Admin reserves the right to Approve or Reject every new registration.
The Admin has the right to request KYC documents (e.g., Caste Certificate, Aadhaar Card, etc.) to verify membership.

4. Privacy & Data Security 🔒
The App Admin guarantees that user information will be used only for internal community purposes.
Data will not be sold or shared with any third party.
Please submit your data carefully and correctly.

5. User Conduct Rules 🚫
Users must not post any misconduct, abusive posts, or fake information on the app.
The App Admin has the right to delete the account for such violations.
Religious, political, or inflammatory content is strictly prohibited in any public post.

6. Terms & Conditions 📄
Users must click on "I agree to the Terms & Privacy Policy" before registering.
Data usage, liability, and conduct rules are clear in this document.

7. Admin Rights 🛡️
The App Admin can suspend or delete a user account at any time if rules are violated.
The App Admin reserves the right to make changes, approve members, and send notifications.
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
                            builder: (_) => const FamilyDirectoryRegistrationScreen(),
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
