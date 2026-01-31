import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Goals, Objectives, Rules and Marathi section for About Us tab.
class AboutTabGoalsContent extends StatelessWidget {
  const AboutTabGoalsContent({super.key});

  static const double _bodyFontSize = 14;
  static const double _headingFontSize = 15;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCard(
          title: '🌼 Goal and Objectives for the Unification of the 19 Sub-castes of the Scattered Sonar Community 🌼',
          children: [
            _p('Today\'s era is one of progress, but also of fragmentation. While a race for progress is underway in every field, our brothers and sisters from the Sonar community are slowly scattering in different directions. Whether in villages, cities, or abroad—our people are everywhere, but contact, affection, and recognition among them are gradually being lost.'),
            _p('This pain resides in every community-loving heart—"Our community should come together, our youth should receive guidance, and the honor of our community should shine brightly once again."'),
            _heading('✨ Our Goal:'),
            _p('"To bring together all the components of the entire Sonar community and establish a strong, well-organized, and progressive society."'),
            _p('We are all bound by the same roots—our traditions, our values, our identity as Sonars; it is not merely a profession, but a culture. Recognizing this, our primary goal is to bring all community members together.'),
            _heading('🌿 Objectives:'),
            _subHeading('Unification:'),
            _p('To connect the branches of the Sonar community in every village, city, and state, building a strong network where every individual feels a sense of belonging.'),
            _subHeading('Educational and Social Progress:'),
            _p('To empower the younger generation of the community through education, competitive exams, business, and skill development.'),
            _subHeading('Social Support:'),
            _p('To provide financial, medical, or educational assistance to needy community members, and to ensure that the community stands together in every crisis.'),
            _subHeading('Communication and Values:'),
            _p('To pass on our culture, traditions, and religious values to the new generation. To foster unity, faith, and mutual respect within the community.'),
            _subHeading('Digital Connectivity:'),
            _p('Recognizing the need of the times, to use digital media for the unification of the community—bringing every Sonar member onto a single platform through websites, mobile apps, online databases, and social media groups.'),
            _heading('❤️ Emotional Message:'),
            _p('"We are goldsmiths — those who recognize and craft gold. But now, time has placed a new responsibility upon us — to rebuild our community. Our strength lies in unity, and let that be our identity. Together, let us bring back the golden age of the Sonar community — where pride shines in every home, love for the community in every heart, and the \'gold of unity\' in every soul!"'),
            _p('This is our resolve — "Let\'s come together, build the community, and brighten the name of Sonar!"'),
            SelectableText.rich(
              TextSpan(
                text: '“Online App for the Unification of the Entire Sonar Community”',
                style: TextStyle(fontSize: _bodyFontSize, color: Colors.grey.shade800, height: 1.45, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            _p('Certain rules and policies are essential for social integration and information management. (User Registration and Social Worker Rules) Below, I have prepared the guidelines in this regard 👇'),
          ],
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: '🪔 Social Worker / Member Registration Rules for Sonar Community Unification / Business Registration / Business Advertising /',
          children: [
            _numbered('1. Purpose', 'The main objective is to bring together all members and social workers of the "Entire Sonar Community". The main purpose is to promote community programs, welfare work, education, and unity.'),
            _numbered('2. Eligibility', 'The following conditions are required for registration:\n• The applicant must be a member of any Sonar sub-caste community.\n• Must be 18 years of age or older.\n• Must have an interest in social service, organization, education, or work for the benefit of the community.\n• The applicant\'s conduct and social character must be excellent.\n• Must not be involved in any criminal / illegal activities.\n\n📸 Other Details: Identity proof (Aadhaar / PAN / Voter ID)'),
            _numbered('4. Responsibilities', 'Registered social workers must:\n• Maintain unity, cooperation, and peace among community members.\n• Stay away from any disputes, disagreements, or propaganda.\n• Ensure transparent use of community funds. The rules of the community must be followed.'),
            _numbered('5. Privacy and Rules', '• Members\' personal information will be kept confidential.\n• Membership will be cancelled if any false or fabricated information is provided.\n• All photos/posts/information uploaded on the app must comply with the community guidelines.\n• Any religious, political, or offensive statements are prohibited.'),
            _numbered('6. Approval Process', '• After registration, the community committee/administration will review the application.\n• Approved applicants will be given a "Membership Number" or "Volunteer ID".\n• Permission will be granted to use the app\'s features (e.g., notifications, event information, service applications).'),
            _numbered('7. Reasons for Membership Cancellation', '• Providing false information\n• Anti-social activities or misconduct\n• Violation of community rules\n• Inactivity (not using the app or participating in activities for a long period)'),
          ],
        ),
        const SizedBox(height: 20),
        _sectionCard(
          title: '🌼 विखुरलेल्या सकळ सोनार समाजाच्या १९ पोटजातींच्या एकत्रीकरणासाठी ध्येय व उद्दिष्ट 🌼',
          children: [
            _p('आजचा काळ प्रगतीचा आहे, पण त्याचबरोबर विस्कळीततेचाही. प्रत्येक क्षेत्रात प्रगतीची शर्यत सुरू असताना, आपल्या सोनार समाजातील बंधुभगिनी मात्र हळूहळू वेगवेगळ्या दिशांना विखुरत चालले आहेत. कधी गावात, कधी शहरात, कधी परदेशात— सगळीकडे आपले लोक आहेत, पण एकमेकांशी संपर्क, स्नेह व ओळख हरवत चालली आहे.'),
            _p('ही वेदना प्रत्येक समाजप्रिय हृदयात आहे — "आपला समाज एकत्र यावा, आपल्या तरुणांना दिशा मिळावी, आणि आपल्या समाजाचा सन्मान पुन्हा तेजस्वी व्हावा."'),
            _heading('✨ आमचे ध्येय:'),
            _p('"सकळ सोनार समाजाचे सर्व घटक एकत्र आणून एक मजबूत, सुसंघटित आणि प्रगतिशील समाज उभा करणे."'),
            _p('आपण सर्व जण एकाच मुळाशी बांधलेले आहोत — आपल्या परंपरा, आपल्या संस्कार, आपले सोनारपण हे केवळ व्यवसाय नाही, तर ती एक संस्कृती आहे. हे ओळखून, सर्व समाजबांधवांना एकत्र आणणे हेच आमचे प्रमुख ध्येय आहे.'),
            _heading('🌿 उद्दिष्टे:'),
            _subHeading('एकत्रीकरण:'),
            _p('प्रत्येक गाव, शहर आणि राज्यातील सोनार समाजाच्या शाखांना एकत्र जोडणे, एक सशक्त नेटवर्क उभारणे, जिथे प्रत्येक व्यक्तीला आपलेपणाची भावना निर्माण होईल.'),
            _subHeading('शैक्षणिक व सामाजिक प्रगती:'),
            _p('समाजातील तरुण पिढीला शिक्षण, स्पर्धा परीक्षां, व्यवसाय आणि कौशल्यविकासाच्या माध्यमातून सक्षम बनवणे.'),
            _subHeading('सामाजिक सहाय्य:'),
            _p('गरजू समाजबांधवांना आर्थिक, वैद्यकीय किंवा शैक्षणिक मदत पुरवणे, आणि प्रत्येक संकटात समाज एकत्र उभा राहावा हे सुनिश्चित करणे.'),
            _subHeading('संवाद व संस्कार:'),
            _p('आपली संस्कृती, परंपरा आणि धार्मिक मूल्ये नव्या पिढीपर्यंत पोहोचवणे. समाजातील एकोपा, श्रद्धा आणि परस्पर आदर वाढवणे.'),
            _subHeading('डिजिटल जोडणी:'),
            _p('आजच्या काळाची गरज ओळखून, समाजाच्या एकत्रीकरणासाठी डिजिटल माध्यमांचा वापर — वेबसाईट, मोबाइल ॲप, ऑनलाइन डेटाबेस, समाजमाध्यम गट यांद्वारे प्रत्येक सोनार बांधवाला एकाच व्यासपीठावर आणणे.'),
            _heading('❤️ भावनिक संदेश:'),
            _p('"आपण सोनार आहोत — सोने ओळखणारे, घडवणारे. पण आता काळाने आपल्यावर एक नवीन जबाबदारी टाकली आहे — आपला समाज पुन्हा घडवण्याची. एकतेतच आपली शक्ती आहे, आणि तीच आपली ओळख होऊ द्या. आपण सर्व जण मिळून सोनार समाजाचे सुवर्णयुग परत आणूया — जिथे प्रत्येक घरात अभिमान, प्रत्येक मनात समाजप्रेम, आणि प्रत्येक हृदयात \'एकतेचे सोने\' चमकत राहील!"'),
            _p('हाच आपला संकल्प — "एकत्र येऊ, समाज घडवू, आणि सोनार नाव उजळवू!"'),
            SelectableText.rich(
              TextSpan(
                text: '"सकळ सोनार समाज एकत्रीकरणासाठी ऑनलाइन ऐप "',
                style: TextStyle(fontSize: _bodyFontSize, color: Colors.grey.shade800, height: 1.45, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            _p('सामाजिक एकात्मता आणि माहिती व्यवस्थापनासाठी काही ठराविक नियम व धोरणे (User Registration आणि Social Worker Rules) ठेवणे अत्यावश्यक आहे. खाली मी त्या संदर्भातील मार्गदर्शक तयार केले आहेत 👇'),
          ],
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: '🪔 सोनार समाज एकत्रीकरणासाठी सामाजिक कार्यकर्ता / सदस्य नोंदणी नियम / व्यवसाय नोंदणी / व्यवसाय जाहिरात /',
          children: [
            _numbered('१. उद्देश (Purpose)', '"सर्व सकळ सोनार समाज" सदस्य आणि सामाजिक कार्यकर्ते यांना एकत्र आणणे हा मुख्य उदिस्त आहे. समाजातील कार्यक्रम, मदतकार्य, शिक्षण, आणि एकात्मता वाढवणे हा मुख्य उद्देश.'),
            _numbered('२. पात्रता (Eligibility)', 'नोंदणीसाठी खालील अटी आवश्यक:\n• अर्जदार कोणत्याही सोनार सबकास्ट समाजाचा सदस्य असावा.\n• वय १८ वर्षे किंवा त्यापेक्षा अधिक असावे.\n• समाजसेवा, संघटन, शिक्षण, किंवा समाजहिताच्या कामात रुची असावी.\n• अर्जदाराचा वर्तणूक व सामाजिक चारित्र्य उत्तम असावा.\n• कोणत्याही गुन्हेगारी / बेकायदेशीर कृतीत सहभाग नसावा.\n\n📸 इतर तपशील: ओळखपत्र (आधार / पॅन / मतदार ओळखपत्र)'),
            _numbered('४. जबाबदाऱ्या (Responsibilities)', 'नोंदणीकृत सामाजिक कार्यकर्त्यांनी:\n• समाजातील सदस्यांमध्ये एकता, सहकार्य, आणि शांती राखावी.\n• कोणत्याही वाद, मतभेद, किंवा प्रचारातून दूर राहावे.\n• समाजाच्या निधीचा पारदर्शक वापर सुनिश्चित करावा.\n• समाजाच्या नियमांचे पालन करावे.'),
            _numbered('५. गोपनीयता व नियम', '• सदस्यांची वैयक्तिक माहिती गुप्त ठेवली जाईल.\n• कोणतीही चुकीची किंवा बनावट माहिती दिल्यास सदस्यत्व रद्द केले जाईल.\n• अॅपवर टाकलेले सर्व फोटो / पोस्ट / माहिती समाजाच्या मार्गदर्शक तत्त्वांनुसार असावी.\n• कोणतेही धार्मिक, राजकीय, किंवा अपमानास्पद विधान निषिद्ध आहे.'),
            _numbered('६. मंजुरी प्रक्रिया (Approval Process)', '• नोंदणी केल्यानंतर समाज समिती / प्रशासन अर्ज तपासेल.\n• योग्य अर्जदारास मंजुरी देऊन "सदस्य क्रमांक" किंवा "कार्यकर्ता आयडी" दिला जाईल.\n• अॅपमधील सुविधा (उदा. सूचना, कार्यक्रम माहिती, सेवा अर्ज) वापरण्याची परवानगी दिली जाईल.'),
            _numbered('७. सदस्यत्व रद्द करण्याचे कारण', '• चुकीची माहिती दिल्यास\n• समाजविरोधी कृत्य किंवा गैरवर्तन\n• समाजाच्या नियमांचे उल्लंघन\n• निष्क्रियता (दीर्घकाळ अॅप वापर न करणे किंवा कार्यात सहभाग न घेणे)'),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          SelectableText(
            title,
            style: TextStyle(
              fontSize: _headingFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _p(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SelectableText(
        text,
        style: TextStyle(fontSize: _bodyFontSize, color: Colors.grey.shade800, height: 1.45),
      ),
    );
  }

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: SelectableText(
        text,
        style: TextStyle(fontSize: _headingFontSize, fontWeight: FontWeight.w600, color: AppTheme.gold),
      ),
    );
  }

  Widget _subHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: SelectableText(
        text,
        style: TextStyle(fontSize: _bodyFontSize, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
      ),
    );
  }

  Widget _numbered(String label, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            '🔹 $label',
            style: TextStyle(fontSize: _bodyFontSize, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 6),
          SelectableText(
            body,
            style: TextStyle(fontSize: _bodyFontSize, color: Colors.grey.shade700, height: 1.45),
          ),
        ],
      ),
    );
  }
}
