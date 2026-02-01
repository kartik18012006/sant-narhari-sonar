import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../services/firestore_service.dart';

/// Admin Approval Detail Screen: Shows pending items for a specific collection/type.
/// Admin can approve, reject, or keep as pending.
class AdminApprovalDetailScreen extends StatefulWidget {
  const AdminApprovalDetailScreen({
    super.key,
    required this.collection,
    this.type,
    required this.title,
  });

  final String collection;
  final String? type;
  final String title;

  @override
  State<AdminApprovalDetailScreen> createState() => _AdminApprovalDetailScreenState();
}

class _AdminApprovalDetailScreenState extends State<AdminApprovalDetailScreen> {
  final FirestoreService _firestore = FirestoreService.instance;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _stream;

  @override
  void initState() {
    super.initState();
    _loadStream();
  }

  void _loadStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection(widget.collection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true);

    if (widget.type != null && widget.collection == 'matrimony') {
      query = query.where('type', isEqualTo: widget.type);
    }

    setState(() {
      _stream = query.snapshots();
    });
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      switch (widget.collection) {
        case 'matrimony':
          await _firestore.updateMatrimonyStatus(id, status);
          break;
        case 'social_workers':
          await _firestore.updateSocialWorkerStatus(id, status);
          break;
        case 'businesses':
          await _firestore.updateBusinessStatus(id, status);
          break;
        case 'news':
          await _firestore.updateNewsStatus(id, status);
          break;
        case 'advertisements':
          await _firestore.updateAdvertisementStatus(id, status);
          break;
        case 'events':
          await _firestore.updateEventStatus(id, status);
          break;
        case 'family_directory':
          await _firestore.updateFamilyDirectoryStatus(id, status);
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${status.toUpperCase()}'),
            backgroundColor: status == 'approved' ? Colors.green : status == 'rejected' ? Colors.red : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stream == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: const Center(child: CircularProgressIndicator()),
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
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No pending items',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All registrations have been reviewed',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              data['id'] = doc.id;

              return _ApprovalItemCard(
                data: data,
                collection: widget.collection,
                onApprove: () => _updateStatus(doc.id, 'approved'),
                onReject: () => _updateStatus(doc.id, 'rejected'),
                onPending: () => _updateStatus(doc.id, 'pending'),
              );
            },
          );
        },
      ),
    );
  }
}

class _ApprovalItemCard extends StatelessWidget {
  const _ApprovalItemCard({
    required this.data,
    required this.collection,
    required this.onApprove,
    required this.onReject,
    required this.onPending,
  });

  final Map<String, dynamic> data;
  final String collection;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onPending;

  String _getTitle() {
    switch (collection) {
      case 'matrimony':
        return data['name'] ?? 'Matrimony Profile';
      case 'social_workers':
        return data['name'] ?? 'Social Worker';
      case 'businesses':
      case 'advertisements':
        return data['businessName'] ?? 'Business';
      case 'news':
        return data['title'] ?? 'News';
      case 'events':
        return data['title'] ?? 'Event';
      case 'family_directory':
        return data['headOfFamily'] ?? 'Family Directory';
      default:
        return 'Item';
    }
  }

  String _getSubtitle() {
    switch (collection) {
      case 'matrimony':
        return '${data['type'] ?? ''} - ${data['phone'] ?? ''}';
      case 'social_workers':
        return data['phone'] ?? '';
      case 'businesses':
      case 'advertisements':
        return data['ownerName'] ?? '';
      case 'news':
        return (data['description'] as String?)?.substring(0, (data['description'] as String?)!.length > 50 ? 50 : (data['description'] as String?)!.length) ?? '';
      case 'events':
        return '${data['date'] ?? ''} - ${data['city'] ?? ''}';
      case 'family_directory':
        return data['phone'] ?? '';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTitle(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSubtitle(),
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    'PENDING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPending,
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text('Pending'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: BorderSide(color: Colors.orange.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
