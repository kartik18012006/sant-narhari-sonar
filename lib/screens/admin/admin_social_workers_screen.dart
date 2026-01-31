import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../services/firestore_service.dart';

/// Admin: Social worker applications from Firestore with Approve / Reject / Delete.
class AdminSocialWorkersScreen extends StatelessWidget {
  const AdminSocialWorkersScreen({super.key});

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
          'Social Workers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.instance.streamSocialWorkers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Text(
                'No social worker applications yet',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final s = list[index];
              final id = s['id'] as String? ?? '';
              final name = s['name'] as String? ?? s['displayName'] as String? ?? '—';
              final subtitle = s['phone'] as String? ?? s['email'] as String? ?? '';
              final status = s['status'] as String? ?? 'pending';
              final photoUrl = s['photoUrl'] as String?;
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: photoUrl != null && photoUrl.isNotEmpty
                                ? Image.network(
                                    photoUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _avatarFallback(name),
                                  )
                                : _avatarFallback(name),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                Text(
                                  subtitle.isNotEmpty ? subtitle : 'Application',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          _StatusChip(status: status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _showDetails(context, s),
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

  Widget _avatarFallback(String name) {
    return SizedBox(
      width: 48,
      height: 48,
      child: CircleAvatar(
        backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
        child: Text(
          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
          style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> s) {
    final photoUrl = s['photoUrl'] as String?;
    String _v(dynamic v) => v == null ? '—' : v.toString();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
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
              if (photoUrl != null && photoUrl.isNotEmpty) ...[
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      photoUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.person, size: 80, color: Colors.grey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _detailRow('Name', _v(s['name'])),
              _detailRow('Phone', _v(s['phone'])),
              _detailRow('Email', _v(s['email'])),
              _detailRow('Address', _v(s['address'])),
              _detailRow('Subcaste', _v(s['subcaste'])),
              _detailRow('Date of Birth', _v(s['dateOfBirth'])),
              _detailRow('Years of Experience', _v(s['yearsOfExperience'])),
              _detailRow('Specialization', _v(s['specialization'])),
              _detailRow('Organization', _v(s['organization'])),
              _detailRow('Description', _v(s['description'])),
              _detailRow('Passport', _v(s['passport'])),
              _detailRow('Pan Card', _v(s['panCard'])),
              _detailRow('Status', _v(s['status'])),
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
    await FirestoreService.instance.updateSocialWorkerStatus(id, status);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Application $status')));
    }
  }

  Future<void> _delete(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text('Are you sure you want to delete this social worker application?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Delete', style: TextStyle(color: Colors.red.shade700))),
        ],
      ),
    );
    if (confirm == true) {
      await FirestoreService.instance.deleteSocialWorker(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application deleted')));
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
