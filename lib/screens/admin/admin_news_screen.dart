import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../services/firestore_service.dart';

/// Admin: list news from Firestore.
class AdminNewsScreen extends StatelessWidget {
  const AdminNewsScreen({super.key});

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
          'News',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.instance.streamNews(limit: 100),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Text(
                'No news yet',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final n = list[index];
              final id = n['id'] as String? ?? '';
              final title = n['title'] as String? ?? '—';
              final description = n['description'] as String? ?? '';
              final status = n['status'] as String? ?? 'pending';
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
                            child: const Icon(Icons.article, color: AppTheme.gold, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                if (description.isNotEmpty)
                                  Text(
                                    description,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          _StatusChip(status: status),
                        ],
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
    await FirestoreService.instance.updateNewsStatus(id, status);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('News $status')));
    }
  }

  Future<void> _delete(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete News'),
        content: const Text('Are you sure you want to delete this news item?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Delete', style: TextStyle(color: Colors.red.shade700))),
        ],
      ),
    );
    if (confirm == true && id.isNotEmpty) {
      await FirestoreService.instance.deleteNews(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('News deleted')));
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
