import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../services/firestore_service.dart';

/// Admin: Family Directory entries from Firestore with Approve / Reject / Delete.
class AdminFamilyDirectoryScreen extends StatelessWidget {
  const AdminFamilyDirectoryScreen({super.key});

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
          'Family Directory',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.instance.streamFamilyDirectory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Text(
                'No family directory entries yet',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final f = list[index];
              final id = f['id'] as String? ?? '';
              final name = f['name'] as String? ?? f['displayName'] as String? ?? '—';
              final subtitle = f['relation'] as String? ?? f['village'] as String? ?? '';
              final status = f['status'] as String? ?? 'pending';
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
                                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                if (subtitle.isNotEmpty)
                                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          _StatusChip(status: status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _showDetails(context, f),
                        icon: Icon(Icons.info_outline, size: 18, color: Colors.grey.shade700),
                        label: Text('View details', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                      ),
                      const SizedBox(height: 4),
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

  void _showDetails(BuildContext context, Map<String, dynamic> f) {
    String _v(dynamic v) => v == null ? '—' : v.toString();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              _detailRow('Name', _v(f['name'])),
              _detailRow('Relation', _v(f['relation'])),
              _detailRow('Village / City', _v(f['village'])),
              _detailRow('Contact', _v(f['contact'])),
              _detailRow('Passport', _v(f['passport'])),
              _detailRow('Pan Card', _v(f['panCard'])),
              _detailRow('Status', _v(f['status'])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    if (value == '—' && label != 'Status') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String id, String status) async {
    await FirestoreService.instance.updateFamilyDirectoryStatus(id, status);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Entry $status')));
    }
  }

  Future<void> _delete(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this family directory entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Delete', style: TextStyle(color: Colors.red.shade700))),
        ],
      ),
    );
    if (confirm == true) {
      await FirestoreService.instance.deleteFamilyDirectoryEntry(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry deleted')));
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
