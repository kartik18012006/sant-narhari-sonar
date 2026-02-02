import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../app_theme.dart';
import '../payment_config.dart';
import '../services/language_service.dart';
import '../widgets/responsive_wrapper.dart';
import 'about_sant_narhari_screen.dart';
import 'birthdays_screen.dart';
import 'business_list_screen.dart';
import 'advertisement_terms_screen.dart';
import 'create_event_screen.dart';
import 'create_news_screen.dart';
import 'my_events_screen.dart';
import 'news_search_screen.dart';
import 'family_directory_screen.dart';
import 'feedback_screen.dart';
import 'matrimony_search_screen.dart';
import 'payment_screen.dart';
import 'social_workers_screen.dart';

/// Explore tab: Community Features, Matrimony, About Shree Sant Narhari, feature grid.
/// Every feature and payment logic matches APK exactly.
class ExploreTabScreen extends StatelessWidget {
  const ExploreTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final lang = LanguageService.instance;
        return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          lang.pick('EXPLORE', 'एक्सप्लोर'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: ResponsiveWrapper(
        maxWidth: kIsWeb ? 1200 : double.infinity,
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            kIsWeb ? 24 : 20,
            20,
            kIsWeb ? 24 : 20,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.pick('Community Features', 'समुदाय वैशिष्ट्ये'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                lang.pick('Discover and connect with the Sonar community', 'सोनार समुदायाशी जोडा'),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              // Matrimony card
              _matrimonyCard(context),
              const SizedBox(height: 16),
              // About Shree Sant Narhari card
              _aboutSantNarhariCard(context),
              const SizedBox(height: 24),
              // Feature grid - responsive columns
              _featureGrid(context),
            ],
          ),
        ),
      ),
        );
      },
    );
  }

  Widget _matrimonyCard(BuildContext context) {
    final lang = LanguageService.instance;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.matrimonyPink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.pick('Matrimony', 'विवाह'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lang.pick('Register for marriage', 'विवाहासाठी नोंदणी'),
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _matrimonyButton(
                  icon: Icons.person_search,
                  label: lang.pick('Search Groom', 'वर शोधक'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MatrimonySearchScreen(isGroom: true),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _matrimonyButton(
                  icon: Icons.person_search,
                  label: lang.pick('Search Bride', 'वधू शोधक'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MatrimonySearchScreen(isGroom: false),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _matrimonyButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: AppTheme.gold),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aboutSantNarhariCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AboutSantNarhariScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.aboutBrown.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppTheme.aboutBrown.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.account_balance, color: AppTheme.aboutBrown, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageService.instance.pick('About Shree Sant Narhari', 'श्री संत नरहरी बद्दल'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      LanguageService.instance.pick('Our Goals, Objectives & Community Rules', 'आमची उद्दिष्टे आणि समुदाय नियम'),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureGrid(BuildContext context) {
    final lang = LanguageService.instance;
    final items = [
      _FeatureItem('Family Directory', lang.pick('Family Directory', 'कुटुंब निर्देशिका'), lang.pick('Search & Register', 'शोध आणि नोंदणी'), Icons.family_restroom),
      _FeatureItem('Social Workers', lang.pick('Social Workers', 'सामाजिक कार्यकर्ते'), lang.pick('Search & Register', 'शोध आणि नोंदणी'), Icons.volunteer_activism),
      _FeatureItem('Business', lang.pick('Business', 'व्यवसाय'), lang.pick('List your business in the Sonar community directory', 'सोनार समुदायात व्यवसाय नोंदवा'), Icons.storefront),
      _FeatureItem('Advertisements', lang.pick('Advertisements', 'जाहिराती'), lang.pick('View & List Ads', 'जाहिराती पहा आणि नोंदवा'), Icons.campaign),
      _FeatureItem('News', lang.pick('News', 'बातम्या'), lang.pick('Sonar Community News', 'सोनार समुदाय बातम्या'), Icons.newspaper),
      _FeatureItem('Events', lang.pick('Events', 'कार्यक्रम'), lang.pick('Join & Create', 'सहभागी व्हा आणि तयार करा'), Icons.event),
      _FeatureItem('My Events', lang.pick('My Events', 'माझे कार्यक्रम'), lang.pick('View RSVPs for your events', 'तुमच्या कार्यक्रमांच्या RSVP पहा'), Icons.event_available),
      _FeatureItem('Birthdays', lang.pick('Birthdays', 'वाढदिवस'), lang.pick("Today's Birthdays", 'आजचे वाढदिवस'), Icons.cake),
      _FeatureItem('Feedback', lang.pick('Feedback', 'अभिप्राय'), lang.pick('Share Your Thoughts', 'तुमचे विचार सामायिक करा'), Icons.feedback_outlined),
    ];

    // Responsive grid: 3 columns on desktop, 2 on mobile
    final crossAxisCount = kIsWeb ? 3 : 2;
    final childAspectRatio = kIsWeb ? 1.1 : 1.05;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: childAspectRatio,
      children: items
          .map((e) => _featureCard(
                context: context,
                title: e.titleDisplay,
                subtitle: e.subtitleDisplay,
                icon: e.icon,
                onTap: _onFeatureTap(context, e.key),
              ))
          .toList(),
    );
  }

  VoidCallback? _onFeatureTap(BuildContext context, String key) {
    switch (key) {
      case 'Family Directory':
        return () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FamilyDirectoryScreen()),
          );
        };
      case 'Social Workers':
        return () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SocialWorkersScreen()),
          );
        };
      case 'Business':
        return () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BusinessListScreen()),
          );
        };
      case 'Advertisements':
        return () {
          Navigator.of(context).push(
            MaterialPageRoute<bool>(
              builder: (_) => PaymentScreen(
                featureId: PaymentConfig.advertisement,
                amount: PaymentConfig.advertisementAmount,
              ),
            ),
          ).then((paid) {
            if (paid == true && context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder: (_) => const AdvertisementTermsScreen(),
                ),
              );
            }
          });
        };
      case 'News':
        return () {
          Navigator.of(context).push(
            MaterialPageRoute<bool>(
              builder: (_) => PaymentScreen(
                featureId: PaymentConfig.news,
                amount: PaymentConfig.newsAmount,
              ),
            ),
          ).then((paid) {
            if (paid == true && context.mounted) {
              // Show options: Add News or Search News
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('News / बातम्या'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add_circle_outline, color: AppTheme.gold),
                        title: const Text('Add News / बातमी जोडा'),
                        subtitle: const Text('Create and publish news'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute<bool>(
                              builder: (_) => const CreateNewsScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.search, color: AppTheme.gold),
                        title: const Text('Search News / बातम्या शोधा'),
                        subtitle: const Text('Search existing news'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NewsSearchScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          });
        };
      case 'Events':
        return () {
          Navigator.of(context).push(
            MaterialPageRoute<bool>(
              builder: (_) => PaymentScreen(
                featureId: PaymentConfig.events,
                amount: PaymentConfig.eventsAmount,
              ),
            ),
          ).then((paid) {
            if (paid == true && context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder: (_) => const CreateEventScreen(),
                ),
              );
            }
          });
        };
      case 'My Events':
        return () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MyEventsScreen()),
          );
        };
      case 'Birthdays':
        return () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BirthdaysScreen()),
          );
        };
      case 'Feedback':
        return () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FeedbackScreen()),
          );
        };
      default:
        return () {};
    }
  }

  Widget _featureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.gold, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem(this.key, this.titleDisplay, this.subtitleDisplay, this.icon);
  final String key;
  final String titleDisplay;
  final String subtitleDisplay;
  final IconData icon;
}
