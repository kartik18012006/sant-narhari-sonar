import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sant_narhari_sonar/app_theme.dart';
import 'package:sant_narhari_sonar/screens/about_tab_goals_content.dart';
import 'package:sant_narhari_sonar/services/language_service.dart';
import 'package:sant_narhari_sonar/widgets/responsive_wrapper.dart';

/// About Us tab. Content to be added step by step.
class AboutTabScreen extends StatelessWidget {
  const AboutTabScreen({super.key});

  static const String _leader1Asset = 'assets/leader1.png';
  static const String _leader2Asset = 'assets/leader2.png';

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              lang.pick('About Us', 'आमच्याबद्दल'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
          ),
          body: ResponsiveWrapper(
            maxWidth: kIsWeb ? 800 : double.infinity,
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: kIsWeb ? 24 : 20,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // About Us intro
                  Container(
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
                    child: Text(
                      lang.pick(
                        'Welcome to Sant Narhari Sonar — the app for the unification of the entire Sonar community. Below you will find our leaders, goals, objectives, and registration rules in English and Marathi.',
                        'संत नरहरी सोनार ऐपमध्ये आपले स्वागत आहे — संपूर्ण सोनार समाज एकत्रीकरणासाठी. खाली आमचे नेते, ध्येय, उद्दिष्टे आणि नोंदणी नियम इंग्रजी आणि मराठीत आहेत.',
                      ),
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Leader image – maintain aspect ratio, prevent stretching
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: kIsWeb ? 400 : double.infinity,
                        maxHeight: kIsWeb ? 500 : 600,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Image.asset(
                            _leader1Asset,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppTheme.gold.withValues(alpha: 0.15),
                              child: Icon(Icons.person, size: 80, color: AppTheme.gold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Salutation and contact
                  Container(
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
                        Text(
                          'Mr. Ganesh Krushankant Lone',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.phone_outlined, size: 18, color: AppTheme.gold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '+91 9922338616',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on_outlined, size: 18, color: AppTheme.gold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Flat No. 120, Datta Digambar Residency, Sonewadi Road, Sushant Nagar, Kedgaon, Ahilyanagar, Maharashtra 414005',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Leader 2 image – maintain aspect ratio, prevent stretching
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: kIsWeb ? 400 : double.infinity,
                        maxHeight: kIsWeb ? 500 : 600,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Image.asset(
                            _leader2Asset,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppTheme.gold.withValues(alpha: 0.15),
                              child: Icon(Icons.person, size: 80, color: AppTheme.gold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Leader 2 salutation and contact
                  Container(
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
                        Text(
                          'Digambar Balkrushna Dahale',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.phone_outlined, size: 18, color: AppTheme.gold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '9011449921',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on_outlined, size: 18, color: AppTheme.gold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dahale Niwas, Azad Chowk / Munjoba Chowk, Datt Mandir in Village, A.P. Nimblak, Tel. - Nagar, Dist. Ahilyanagar, Pin - 414111',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Goals, Objectives & Rules (English + Marathi)
                  Text(
                    lang.pick('Goals, Objectives & Rules', 'ध्येय, उद्दिष्टे आणि नियम'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const AboutTabGoalsContent(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
