import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../services/firestore_service.dart';

/// Admin: list business registrations from Firestore with Approve / Reject / Delete.
class AdminBusinessesScreen extends StatelessWidget {
  const AdminBusinessesScreen({super.key});

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
          'Businesses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.instance.streamBusinesses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Text(
                'No business registrations yet',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final b = list[index];
              final id = b['id'] as String? ?? '';
              final name = b['businessName'] as String? ?? '—';
              final subtitle = b['contact'] as String? ?? b['address'] as String? ?? '';
              final status = b['status'] as String? ?? 'pending';
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
                            child: const Icon(Icons.business, color: AppTheme.gold, size: 24),
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
                        onPressed: () => _showDetails(context, b),
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

  void _showDetails(BuildContext context, Map<String, dynamic> b) {
    String _v(dynamic v) => v == null ? '—' : v.toString();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
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
              _detailRow('Business Name', _v(b['businessName'])),
              _detailRow('Description', _v(b['description'])),
              _detailRow('Contact', _v(b['contact'])),
              _detailRow('Address', _v(b['address'])),
              _detailRow('Subcaste', _v(b['subcaste'])),
              _detailRow('Place', _v(b['place'])),
              _detailRow('Business Nature', _v(b['businessNature'])),
              _detailRow('Passport', _v(b['passport'])),
              _detailRow('Pan Card', _v(b['panCard'])),
              _detailRow('Status', _v(b['status'])),
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
    await FirestoreService.instance.updateBusinessStatus(id, status);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Business $status')));
    }
  }

  Future<void> _delete(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Business'),
        content: const Text('Are you sure you want to delete this business registration?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Delete', style: TextStyle(color: Colors.red.shade700))),
        ],
      ),
    );
    if (confirm == true) {
      await FirestoreService.instance.deleteBusiness(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Business deleted')));
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
