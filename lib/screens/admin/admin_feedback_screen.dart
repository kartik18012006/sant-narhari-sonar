import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../services/firestore_service.dart';

/// Admin: list and delete user feedback.
class AdminFeedbackScreen extends StatelessWidget {
  const AdminFeedbackScreen({super.key});

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
          'Feedback',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.instance.streamFeedback(),
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
                    Icon(Icons.feedback_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No feedback found',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final f = list[index];
              final text = f['text'] as String? ?? '';
              final userDisplayName = f['userDisplayName'] as String? ?? '';
              final userEmail = f['userEmail'] as String? ?? '';
              final createdAt = f['createdAt'];
              final id = f['id'] as String? ?? '';
              final status = f['status'] as String? ?? 'pending';
              String dateStr = 'Recently';
              if (createdAt != null) {
                if (createdAt is Timestamp) {
                  dateStr = '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}';
                }
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            userDisplayName.isNotEmpty ? userDisplayName : (userEmail.isNotEmpty ? userEmail : 'User'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              _StatusChip(status: status),
                              const SizedBox(width: 8),
                              Text(
                                dateStr,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (userEmail.isNotEmpty && userDisplayName != userEmail)
                        Text(
                          userEmail,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        text,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (status != 'approved')
                            TextButton.icon(
                              onPressed: () => _updateStatus(context, id, 'approved'),
                              icon: Icon(Icons.check_circle, size: 18, color: Colors.green.shade700),
                              label: Text('Approve', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                            ),
                          if (status != 'rejected')
                            TextButton.icon(
                              onPressed: () => _updateStatus(context, id, 'rejected'),
                              icon: Icon(Icons.cancel, size: 18, color: Colors.orange.shade700),
                              label: Text('Reject', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w600)),
                            ),
                          TextButton.icon(
                            onPressed: () => _delete(context, id),
                            icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                            label: Text('Delete', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600)),
                          ),
                        ],
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

  Future<void> _updateStatus(BuildContext context, String id, String status) async {
    await FirestoreService.instance.updateFeedbackStatus(id, status);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Feedback $status')));
    }
  }

  Future<void> _delete(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: const Text('Are you sure you want to delete this feedback?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Delete', style: TextStyle(color: Colors.red.shade700))),
        ],
      ),
    );
    if (confirm == true && id.isNotEmpty) {
      await FirestoreService.instance.deleteFeedback(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback deleted')));
      }
    }
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
