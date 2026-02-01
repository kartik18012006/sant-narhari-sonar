import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app_theme.dart';
import 'admin_approval_detail_screen.dart';

/// Admin Approvals Dashboard: Shows all pending registrations with counts.
/// Admin can approve/reject/pending each form.
class AdminApprovalsDashboardScreen extends StatefulWidget {
  const AdminApprovalsDashboardScreen({super.key});

  @override
  State<AdminApprovalsDashboardScreen> createState() => _AdminApprovalsDashboardScreenState();
}

class _AdminApprovalsDashboardScreenState extends State<AdminApprovalsDashboardScreen> {
  int _pendingBrides = 0;
  int _pendingGrooms = 0;
  int _pendingSocialWorkers = 0;
  int _pendingBusinesses = 0;
  int _pendingNews = 0;
  int _pendingAdvertisements = 0;
  int _pendingEvents = 0;
  int _pendingFamilyDirectory = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final counts = await Future.wait([
      _getPendingCount('matrimony', 'bride'),
      _getPendingCount('matrimony', 'groom'),
      _getPendingCount('social_workers', null),
      _getPendingCount('businesses', null),
      _getPendingCount('news', null),
      _getPendingCount('advertisements', null),
      _getPendingCount('events', null),
      _getPendingCount('family_directory', null),
    ]);

    if (mounted) {
      setState(() {
        _pendingBrides = counts[0];
        _pendingGrooms = counts[1];
        _pendingSocialWorkers = counts[2];
        _pendingBusinesses = counts[3];
        _pendingNews = counts[4];
        _pendingAdvertisements = counts[5];
        _pendingEvents = counts[6];
        _pendingFamilyDirectory = counts[7];
      });
    }
  }

  Future<int> _getPendingCount(String collection, String? type) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection(collection)
          .where('status', isEqualTo: 'pending');
      
      if (type != null && collection == 'matrimony') {
        query = query.where('type', isEqualTo: type);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

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
          'Admin Approvals',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey.shade800),
            onPressed: _loadCounts,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCounts,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            Text(
              'Pending Approvals',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Review and approve registrations submitted after payment',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            _ApprovalTile(
              icon: Icons.person,
              title: 'Bride Registrations',
              subtitle: 'Matrimony - Bride profiles',
              count: _pendingBrides,
              onTap: () => _navigateToApprovals('matrimony', 'bride', 'Bride Registrations'),
            ),
            const SizedBox(height: 12),
            _ApprovalTile(
              icon: Icons.person_outline,
              title: 'Groom Registrations',
              subtitle: 'Matrimony - Groom profiles',
              count: _pendingGrooms,
              onTap: () => _navigateToApprovals('matrimony', 'groom', 'Groom Registrations'),
            ),
            const SizedBox(height: 12),
            _ApprovalTile(
              icon: Icons.volunteer_activism,
              title: 'Social Workers',
              subtitle: 'Social worker applications',
              count: _pendingSocialWorkers,
              onTap: () => _navigateToApprovals('social_workers', null, 'Social Workers'),
            ),
            const SizedBox(height: 12),
            _ApprovalTile(
              icon: Icons.business,
              title: 'Businesses',
              subtitle: 'Business registrations',
              count: _pendingBusinesses,
              onTap: () => _navigateToApprovals('businesses', null, 'Businesses'),
            ),
            const SizedBox(height: 12),
            _ApprovalTile(
              icon: Icons.article,
              title: 'News',
              subtitle: 'Community news articles',
              count: _pendingNews,
              onTap: () => _navigateToApprovals('news', null, 'News'),
            ),
            const SizedBox(height: 12),
            _ApprovalTile(
              icon: Icons.campaign,
              title: 'Advertisements',
              subtitle: 'Advertisement listings',
              count: _pendingAdvertisements,
              onTap: () => _navigateToApprovals('advertisements', null, 'Advertisements'),
            ),
            const SizedBox(height: 12),
            _ApprovalTile(
              icon: Icons.event,
              title: 'Events',
              subtitle: 'Community events',
              count: _pendingEvents,
              onTap: () => _navigateToApprovals('events', null, 'Events'),
            ),
            const SizedBox(height: 12),
            _ApprovalTile(
              icon: Icons.family_restroom,
              title: 'Family Directory',
              subtitle: 'Family directory entries',
              count: _pendingFamilyDirectory,
              onTap: () => _navigateToApprovals('family_directory', null, 'Family Directory'),
            ),
            const SizedBox(height: 24),
            // Total counts section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pending',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_pendingBrides + _pendingGrooms + _pendingSocialWorkers + _pendingBusinesses + _pendingNews + _pendingAdvertisements + _pendingEvents + _pendingFamilyDirectory} registrations awaiting approval',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToApprovals(String collection, String? type, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminApprovalDetailScreen(
          collection: collection,
          type: type,
          title: title,
        ),
      ),
    ).then((_) => _loadCounts());
  }
}

class _ApprovalTile extends StatelessWidget {
  const _ApprovalTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: count > 0 ? Colors.orange.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: count > 0 ? Colors.orange.shade300 : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: count > 0 ? Colors.orange.shade700 : Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}
