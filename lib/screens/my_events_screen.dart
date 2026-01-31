import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import 'event_rsvps_screen.dart';

/// Lists events created by the current user. Creator can open each event to view RSVP form submissions.
class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  static String _v(dynamic v) => v == null ? '—' : v.toString();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'My Events / माझे कार्यक्रम',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Sign in to view your events and RSVPs',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
        title: const Text(
          'My Events / माझे कार्यक्रम',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.instance.streamEventsByUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'You haven\'t created any events yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create an event from the Events tile to see it here and receive RSVPs.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final e = list[index];
              final id = e['id'] as String? ?? '';
              final title = _v(e['title']);
              final date = _v(e['date']);
              final status = e['status'] as String? ?? 'pending';
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
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.event, color: AppTheme.gold, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                if (date.isNotEmpty && date != '—')
                                  Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          _StatusChip(status: status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EventRsvpsScreen(
                                  eventId: id,
                                  eventTitle: title,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.people_outline, size: 18),
                          label: const Text('View RSVPs'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.gold,
                            side: const BorderSide(color: AppTheme.gold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (status == 'approved') color = Colors.green;
    if (status == 'rejected') color = Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
