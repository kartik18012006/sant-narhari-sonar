import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'create_ad_screen.dart';

/// Advertisement Terms & Conditions — must agree before registration form.
class AdvertisementTermsScreen extends StatefulWidget {
  const AdvertisementTermsScreen({super.key});

  @override
  State<AdvertisementTermsScreen> createState() => _AdvertisementTermsScreenState();
}

class _AdvertisementTermsScreenState extends State<AdvertisementTermsScreen> {
  bool _agreed = false;

  static const String _titleEn = 'Advertisement Terms & Conditions';
  static const String _titleMr = 'जाहिरात नियम व अटी';

  static const String _bodyMr = r'''
Business चा मालक हा सोनार समाज्यातील कुठल्याही एका पोटजातीचा सभासद असणे गरजेचे आहे.

१. माहिती खरी आणि स्पष्ट असावी 📝
जाहिरात केलेली माहिती खरी, अचूक आणि दिशाभूल करणारी नसावी.
उत्पादनाची किंमत, वैशिष्ट्ये, ऑफर, सवलती इत्यादींमध्ये स्पष्टता असावी.

२. ग्राहक पारदर्शकता 🤝
उत्पादन/सेवेचा डिलिव्हरी वेळ, डिलिव्हरी शुल्क, परतावा/परतावा धोरण स्पष्टपणे नमूद करणे महत्त्वाचे आहे.
"अटी आणि शर्ती लागू", "मर्यादित ऑफर" असे लिहिले असल्यास तपशील सहज उपलब्ध ठेवणे बंधनकारक आहे.

३. ग्राहक संरक्षण कायदा (CPA २०१९) नुसार नियम ⚖️
चुकीची/खोटी जाहिरात दिल्यास ग्राहक तक्रार करू शकतात.
दिशाभूल करणाऱ्या जाहिरातींमुळे दंड किंवा कारवाई होऊ शकते.

४. डेटा गोपनीयता आणि सुरक्षा 🔒
ग्राहकाची वैयक्तिक माहिती (नाव, मोबाईल, ईमेल) सुरक्षित ठेवणे ही व्यावसायिकाची जबाबदारी आहे.
प्रमोशनल ईमेल/संदेश पाठवण्यासाठी ग्राहकाची संमती आवश्यक आहे (ऑप्ट-इन संमती).

५. गुगल, फेसबुक, इंस्टाग्राम सारख्या प्लॅटफॉर्मचे नियम 📱
प्रत्येक जाहिरात प्लॅटफॉर्मचे स्वतःचे नियम (धोरण मार्गदर्शक तत्त्वे) असतात. उदाहरणार्थ:
फेसबुक जाहिराती: उत्पादन कायदेशीर आहे की नाही, ते बेकायदेशीर आहे की बनावट आहे, हे तपासले जाते.
गुगल जाहिराती: संवेदनशील सामग्री, खोट्या जाहिराती, ड्रग्ज, शस्त्रे इत्यादींसाठी मर्यादा आहेत.

६. जीएसटी / इनव्हॉइस नियम (लागू असल्यास) 🧾
तुम्ही विकत असलेल्या उत्पादनावर आणि वार्षिक उलाढालीच्या मर्यादेवर अवलंबून, GST नोंदणी आवश्यक आहे.
ग्राहकाला आवश्यक असल्यास कर चलन (tax invoice) प्रदान करावे लागेल.

७. ट्रेडमार्क आणि कॉपीराइट नियम ©
परवानगीशिवाय इतर ब्रँडचे ट्रेडमार्क, लोगो किंवा फोटो वापरू नयेत.
कॉपीराइट केलेली सामग्री वापरण्यासाठी निर्मात्याची परवानगी आवश्यक आहे.
''';

  static const String _bodyEn = r'''
The business owner must be a member of any sub-caste of the Sonar community.

1. Information Must Be True and Clear 📝
The advertised information must be true, accurate, and not misleading.
Information about product price, features, offers, and discounts must be clear and transparent.

2. Customer Transparency 🤝
It is important to clearly state the delivery time, delivery charges, and return/refund policy for the product/service.
If phrases like "Terms and Conditions Apply" or "Limited Offer" are used, the details must be easily accessible.

3. Rules According to Consumer Protection Act (CPA 2019) ⚖️
Customers can file a complaint for false or misleading advertisements.
Misleading ads can lead to fines or legal action.

4. Data Privacy & Security 🔒
It is the business owner's responsibility to keep customer's personal information (name, mobile, email) secure.
Customer's consent (opt-in) is required for sending promotional emails/messages.

5. Platform Rules (Google, Facebook, etc.) 📱
Each advertising platform has its own policy guidelines. For example:
Facebook Ads: Policies regarding legal, illegal, or counterfeit products.
Google Ads: Restrictions on sensitive content, false advertisements, drugs, weapons, etc.

6. GST / Invoice Rules (if applicable) 🧾
GST registration may be required depending on the product and annual turnover.
Customers must be provided with a proper tax invoice when required.

7. Trademark & Copyright Rules ©
Do not use other brands' trademarks, logos, or photos without permission.
Permission from the creator is required to use copyrighted material.
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
                            builder: (_) => const CreateAdScreen(),
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
