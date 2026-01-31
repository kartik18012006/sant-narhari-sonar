import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/language_service.dart';
import 'notifications_screen.dart';
import 'rsvp_form_screen.dart';
import 'view_all_ads_screen.dart';
import 'view_all_events_screen.dart';
import 'view_all_news_screen.dart';

// Mock data for home (APK-style) when Firestore has no ads/events/news.
final List<Map<String, dynamic>> _mockAdvertisements = [
  {'title': 'Sonar Samaj Meet 2025', 'subtitle': 'Annual gathering — Pune'},
  {'title': 'Jewellery Exhibition', 'subtitle': 'Community showcase'},
  {'title': 'Matrimony Meet-up', 'subtitle': 'Sant Narhari Sonar'},
];

final List<Map<String, dynamic>> _mockEvents = [
  {'id': '', 'title': 'Sonar Samaj Diwali Milan', 'date': '15 Nov 2025', 'location': 'Pune', 'description': 'Community Diwali celebration.'},
  {'id': '', 'title': 'Annual General Meeting', 'date': '20 Dec 2025', 'location': 'Mumbai', 'description': 'AGM and cultural program.'},
  {'id': '', 'title': 'Youth Talent Show', 'date': '5 Jan 2026', 'location': 'Nashik', 'description': 'Music and dance for youth.'},
];

final List<Map<String, dynamic>> _mockNews = [
  {'title': 'Welcome to Sant Narhari Sonar App', 'createdAt': null, 'description': 'Connect with the Sonar community. Use Explore for directory, matrimony, events and more.'},
  {'title': 'New Features: Family Directory & Matrimony', 'createdAt': null, 'description': 'Register and search family directory. Create matrimony profile after payment.'},
  {'title': 'Community News Updates', 'createdAt': null, 'description': 'News here expires in 24 hours. Post from Explore → News.'},
];

/// Home tab: Featured Advertisements, Upcoming Events (with RSVP), Sonar Community News.
/// Logic matches APK HomeDashboardScreen: ads (featured 24h), events with RSVP, news (expires 24h).
/// Mock data shown when Firestore is empty (matches APK demo content).
class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  String _displayName = 'User';

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) return;
    try {
      final profile = await FirestoreService.instance.getUserProfile(user.uid);
      final name = profile?['displayName'] as String? ??
          user.displayName ??
          user.email?.split('@').first ??
          user.phoneNumber ??
          'User';
      if (mounted) {
        setState(() => _displayName = name);
      }
    } catch (_) {
      final u = FirebaseAuthService.instance.currentUser;
      if (mounted && u != null) {
        setState(() => _displayName = u.displayName ?? u.email?.split('@').first ?? u.phoneNumber ?? 'User');
      }
    }
  }

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
              icon: Icon(Icons.menu, color: Colors.grey.shade800),
              onPressed: () {
                Scaffold.maybeOf(context)?.openDrawer();
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Samaj Community App',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${lang.pick('Namaste', 'नमस्कार')}, $_displayName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade800),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                  context,
                  title: lang.pick('Featured Advertisements', 'विशेष जाहिराती'),
                  onViewAll: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ViewAllAdsScreen()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 6),
                  child: Text(
                    lang.pick('Featured placement for 24 hours', '२४ तास विशेष जागा'),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
                _featuredAdsSection(context),
                const SizedBox(height: 24),
                _sectionHeader(
                  context,
                  title: lang.pick('Upcoming Events', 'आगामी कार्यक्रम'),
                  onViewAll: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ViewAllEventsScreen()),
                  ),
                ),
                _upcomingEventsSection(context),
                const SizedBox(height: 24),
                _sectionHeader(
                  context,
                  title: lang.pick('Sonar Community News', 'सोनार समुदाय बातम्या'),
                  onViewAll: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ViewAllNewsScreen()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 6),
                  child: Text(
                    lang.pick('News automatically expires after 24 hours.', 'बातम्या २४ तासांनंतर स्वयं समाप्त.'),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
                _latestNewsSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    required VoidCallback onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            child: Text(LanguageService.instance.pick('View All', 'सर्व पहा'), style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _featuredAdsSection(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.instance.streamAdvertisementsApproved(limit: 10),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 140,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.gold),
            ),
          );
        }
        final list = snapshot.data ?? [];
        final displayList = list.isEmpty ? _mockAdvertisements : list;
        return SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final ad = displayList[index];
              final title = ad['title'] as String? ?? 'Advertisement';
              final subtitle = ad['subtitle'] as String? ?? '';
              return Padding(
                padding: EdgeInsets.only(right: index < displayList.length - 1 ? 12 : 0),
                child: _adCard(
                  title: title,
                  subtitle: subtitle.isNotEmpty ? subtitle : 'Community',
                  icon: Icons.campaign,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _adCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.gold, size: 32),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _upcomingEventsSection(BuildContext context) {
    final userId = FirebaseAuthService.instance.currentUser?.uid ?? '';
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.instance.streamEvents(limit: 10),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.gold)),
            ),
          );
        }
        final list = snapshot.data ?? [];
        final displayList = list.isEmpty ? _mockEvents : list;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (int i = 0; i < displayList.length; i++) ...[
                _EventCardWithRsvp(
                  eventId: displayList[i]['id'] as String? ?? '',
                  title: displayList[i]['title'] as String? ?? 'Event',
                  date: displayList[i]['date'] as String? ?? '',
                  location: displayList[i]['location'] as String? ?? '',
                  description: displayList[i]['description'] as String?,
                  userId: userId,
                  eventType: displayList[i]['eventType'] as String? ?? 'free',
                  ticketAmount: displayList[i]['ticketAmount'],
                ),
                if (i < displayList.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _latestNewsSection(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.instance.streamNewsApproved(limit: 10),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.gold)),
            ),
          );
        }
        final list = snapshot.data ?? [];
        final displayList = list.isEmpty ? _mockNews : list;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (int i = 0; i < displayList.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i < displayList.length - 1 ? 12 : 0),
                  child: _newsCard(
                    title: displayList[i]['title'] as String? ?? 'News',
                    date: _formatNewsDate(displayList[i]['createdAt']),
                    description: displayList[i]['description'] as String? ?? '',
                    onTap: () {},
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatNewsDate(dynamic createdAt) {
    if (createdAt == null) return 'Recently';
    DateTime dt;
    if (createdAt is Timestamp) {
      dt = createdAt.toDate();
    } else if (createdAt is DateTime) {
      dt = createdAt;
    } else {
      return 'Recently';
    }
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _newsCard({
    required String title,
    required String date,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
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
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.campaign_outlined, color: AppTheme.gold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}

/// Event card with RSVP button. Shows "RSVP" or "RSVP'd" based on Firestore; opens RSVP form on tap.
/// Shows Free or ticket amount (₹) when eventType/ticketAmount provided.
class _EventCardWithRsvp extends StatelessWidget {
  const _EventCardWithRsvp({
    required this.eventId,
    required this.title,
    required this.date,
    required this.location,
    this.description,
    required this.userId,
    this.eventType = 'free',
    this.ticketAmount,
  });

  final String eventId;
  final String title;
  final String date;
  final String location;
  final String? description;
  final String userId;
  final String eventType;
  final dynamic ticketAmount;

  String get _ticketLabel {
    if (eventType == 'paid' && ticketAmount != null) {
      final n = ticketAmount is num ? ticketAmount.toInt() : int.tryParse(ticketAmount.toString());
      if (n != null && n > 0) return '₹$n entry';
      return 'Paid';
    }
    return 'Free';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: userId.isEmpty ? null : FirestoreService.instance.streamHasUserRsvpedForEvent(eventId, userId),
      builder: (context, rsvpSnapshot) {
        final hasRsvped = rsvpSnapshot.data ?? false;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_today, color: AppTheme.gold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _ticketLabel == 'Free'
                            ? Colors.green.withValues(alpha: 0.12)
                            : AppTheme.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _ticketLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _ticketLabel == 'Free' ? Colors.green.shade700 : AppTheme.gold,
                        ),
                      ),
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        location,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
              if (userId.isEmpty)
                Text(
                  'Sign in to RSVP',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                )
              else if (hasRsvped)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 18, color: Colors.green.shade700),
                      const SizedBox(width: 6),
                      Text(
                        "RSVP'd",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                      ),
                    ],
                  ),
                )
              else
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => RsvpFormScreen(eventId: eventId, eventTitle: title),
                      ),
                    );
                    if (result == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("You've RSVPed. See you at the event!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('RSVP', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        );
      },
    );
  }
}
