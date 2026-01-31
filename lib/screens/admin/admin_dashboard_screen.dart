import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';
import 'admin_advertisements_screen.dart';
import 'admin_businesses_screen.dart';
import 'admin_events_screen.dart';
import 'admin_family_directory_screen.dart';
import 'admin_feedback_screen.dart';
import 'admin_news_screen.dart';
import 'admin_registrations_screen.dart';
import 'admin_social_workers_screen.dart';
import 'admin_users_screen.dart';

/// Admin Dashboard: tiles to Users, Businesses, Advertisements, News, Events, Family Directory, Registrations, Social Workers, Feedback.
/// Verifies user is admin on load; if not, pops back (defense in depth).
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verifyAdmin());
  }

  Future<void> _verifyAdmin() async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final admin = await FirestoreService.instance.isAdmin(user.uid);
    if (!mounted) return;
    if (!admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin access required. You do not have permission.')),
      );
      Navigator.of(context).pop();
      return;
    }
    setState(() => _verified = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_verified) {
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
            'Admin Dashboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
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
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.grey.shade800),
            onPressed: () async {
              await FirebaseAuthService.instance.signOut();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          Text(
            'Welcome, Admin',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Manage users, content and feedback from the sections below.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          _AdminTile(
            icon: Icons.people,
            title: 'Users',
            subtitle: 'Manage user accounts',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.business,
            title: 'Businesses',
            subtitle: 'Business registrations',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminBusinessesScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.campaign,
            title: 'Advertisements',
            subtitle: 'Manage advertisements',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminAdvertisementsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.article,
            title: 'News',
            subtitle: 'Review & manage news',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminNewsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.calendar_today,
            title: 'Events',
            subtitle: 'Manage events',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminEventsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.folder_shared,
            title: 'Family Directory',
            subtitle: 'Family directory entries',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminFamilyDirectoryScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.how_to_reg,
            title: 'Registrations',
            subtitle: 'Matrimony & other registrations',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminRegistrationsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.volunteer_activism,
            title: 'Social Workers',
            subtitle: 'Social worker applications',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminSocialWorkersScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.feedback,
            title: 'Feedback',
            subtitle: 'User feedback submissions',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminFeedbackScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.gold, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}
