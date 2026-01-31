import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firestore_service.dart';
import 'rsvp_form_screen.dart';

/// Full list of events from Firestore. Filter by Free/Paid. RSVP opens form (same logic as home).
class ViewAllEventsScreen extends StatefulWidget {
  const ViewAllEventsScreen({super.key});

  @override
  State<ViewAllEventsScreen> createState() => _ViewAllEventsScreenState();
}

class _ViewAllEventsScreenState extends State<ViewAllEventsScreen> {
  /// 'all' | 'free' | 'paid'
  String _filter = 'all';

  static bool _eventMatchesFilter(Map<String, dynamic> ev, String filter) {
    if (filter == 'all') return true;
    final type = (ev['eventType'] as String?) ?? 'free';
    return type == filter;
  }

  static String _eventTicketLabel(Map<String, dynamic> ev) {
    final type = (ev['eventType'] as String?) ?? 'free';
    if (type == 'paid') {
      final amount = ev['ticketAmount'];
      if (amount != null) {
        final n = amount is num ? amount.toInt() : int.tryParse(amount.toString());
        if (n != null && n > 0) return '₹$n entry';
      }
      return 'Paid';
    }
    return 'Free';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'All Events',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Text(
                  'Filter: ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                ),
                _filterChip('All', 'all'),
                const SizedBox(width: 8),
                _filterChip('Free', 'free'),
                const SizedBox(width: 8),
                _filterChip('Paid', 'paid'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService.instance.streamEventsApproved(limit: 100),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }
                final list = snapshot.data ?? [];
                final filtered = list.where((ev) => _eventMatchesFilter(ev, _filter)).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            list.isEmpty
                                ? 'No events yet.\nList one from Explore → Events.'
                                : 'No $_filter events.\nTry another filter.',
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ev = filtered[index];
                    final eventId = ev['id'] as String? ?? '';
                    final title = ev['title'] as String? ?? 'Event';
                    final date = ev['date'] as String? ?? '';
                    final location = ev['location'] as String? ?? '';
                    final ticketLabel = _eventTicketLabel(ev);
                    return Padding(
                      padding: EdgeInsets.only(bottom: index < filtered.length - 1 ? 12 : 0),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: ticketLabel == 'Free'
                                          ? Colors.green.withValues(alpha: 0.12)
                                          : AppTheme.gold.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      ticketLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: ticketLabel == 'Free'
                                            ? Colors.green.shade700
                                            : AppTheme.gold,
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
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RsvpFormScreen(eventId: eventId, eventTitle: title),
                                  ),
                                );
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

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (v) => setState(() => _filter = value),
      selectedColor: AppTheme.gold.withValues(alpha: 0.25),
      checkmarkColor: AppTheme.gold,
    );
  }
}
