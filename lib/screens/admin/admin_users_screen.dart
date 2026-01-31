import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app_theme.dart';
import 'admin_user_detail_screen.dart';

/// Admin: list users from Firestore (users collection). Tap opens User Detail.
class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

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
          'Users',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').orderBy('updatedAt', descending: true).limit(200).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No users yet',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final d = Map<String, dynamic>.from(doc.data());
              d['uid'] = doc.id;
              final displayName = d['displayName'] as String? ?? '—';
              final email = d['email'] as String? ?? '';
              final phone = d['phoneNumber'] as String? ?? '';
              final isAdmin = d['isAdmin'] == true;
              final uid = doc.id;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
                    child: Text(
                      displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : '?',
                      style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    [email, phone].where((e) => e.isNotEmpty).isEmpty
                        ? '—'
                        : [email, phone].where((e) => e.isNotEmpty).join(' • '),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Admin',
                            style: TextStyle(fontSize: 12, color: AppTheme.goldDark, fontWeight: FontWeight.w600),
                          ),
                        ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade500),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdminUserDetailScreen(
                          uid: uid,
                          initialData: d,
                        ),
                      ),
                    ).then((_) {});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
