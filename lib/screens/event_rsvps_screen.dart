import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firestore_service.dart';

/// Shows RSVP form submissions for one event. For event creators only.
class EventRsvpsScreen extends StatelessWidget {
  const EventRsvpsScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  final String eventId;
  final String eventTitle;

  static String _v(dynamic v) => v == null ? '—' : v.toString();

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
          'RSVPs / पुष्ट्या',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              eventTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService.instance.streamEventRsvps(eventId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }
                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No RSVPs yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Responses will appear here when people RSVP.',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final r = list[index];
                    final name = _v(r['displayName']);
                    final phone = _v(r['phone']);
                    final email = _v(r['email']);
                    final createdAt = r['createdAt'];
                    String dateStr = '—';
                    if (createdAt != null) {
                      final dt = createdAt is Timestamp ? createdAt.toDate() : (createdAt is DateTime ? createdAt : null);
                      if (dt != null) dateStr = '${dt.day}/${dt.month}/${dt.year}';
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
                                  child: Text(
                                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                                    style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                      if (dateStr != '—')
                                        Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (phone.isNotEmpty && phone != '—') ...[
                              const SizedBox(height: 10),
                              _row('Phone', phone),
                            ],
                            if (email.isNotEmpty && email != '—') _row('Email', email),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }
}
