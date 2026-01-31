import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../services/firestore_service.dart';

/// Admin: view user details and perform actions (Set/Remove Admin, Suspend, Delete profile).
class AdminUserDetailScreen extends StatelessWidget {
  const AdminUserDetailScreen({
    super.key,
    required this.uid,
    required this.initialData,
  });

  final String uid;
  final Map<String, dynamic> initialData;

  @override
  Widget build(BuildContext context) {
    final displayName =
        initialData['displayName'] as String? ?? '—';
    final email = initialData['email'] as String? ?? '';
    final phone = initialData['phoneNumber'] as String? ?? '';
    final isAdmin = initialData['isAdmin'] == true;
    final isSuspended = initialData['isSuspended'] == true;

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
          'User Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
                child: Text(
                  displayName.isNotEmpty
                      ? displayName.substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ),
            ],
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  phone,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _DetailRow(label: 'User ID', value: uid),
            _DetailRow(label: 'Admin', value: isAdmin ? 'Yes' : 'No'),
            _DetailRow(label: 'Suspended', value: isSuspended ? 'Yes' : 'No'),
            const SizedBox(height: 32),
            // Actions
            if (!isAdmin)
              _ActionButton(
                label: 'Set as Admin',
                icon: Icons.admin_panel_settings,
                onPressed: () => _setAdmin(context, true),
              )
            else
              _ActionButton(
                label: 'Remove Admin',
                icon: Icons.person_off,
                onPressed: () => _setAdmin(context, false),
              ),
            const SizedBox(height: 12),
            if (!isSuspended)
              _ActionButton(
                label: 'Suspend User',
                icon: Icons.block,
                onPressed: () => _setSuspended(context, true),
              )
            else
              _ActionButton(
                label: 'Unsuspend User',
                icon: Icons.check_circle,
                onPressed: () => _setSuspended(context, false),
              ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Delete User Profile',
              icon: Icons.delete_forever,
              isDestructive: true,
              onPressed: () => _deleteProfile(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setAdmin(BuildContext context, bool value) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(value ? 'Set as Admin' : 'Remove Admin'),
        content: Text(
          value
              ? 'This user will have access to the Admin Panel. Continue?'
              : 'This user will lose admin access. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await FirestoreService.instance.setUserAdmin(uid, value);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value ? 'User set as admin' : 'Admin access removed')),
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _setSuspended(BuildContext context, bool value) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(value ? 'Suspend User' : 'Unsuspend User'),
        content: Text(
          value
              ? 'Suspended users may be restricted from some actions. Continue?'
              : 'User will be unsuspended. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await FirestoreService.instance.setUserSuspended(uid, value);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value ? 'User suspended' : 'User unsuspended')),
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteProfile(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User Profile'),
        content: const Text(
          'This will remove the user profile from the app (Firestore). '
          'The user can still sign in with Auth until removed from Firebase Console. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await FirestoreService.instance.deleteUserProfile(uid);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User profile deleted')),
      );
      Navigator.of(context).pop(true);
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTheme.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: isDestructive ? Colors.red : null),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDestructive ? Colors.red : Colors.grey.shade800,
          side: BorderSide(
            color: isDestructive ? Colors.red : Colors.grey.shade400,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
        ),
      ),
    );
  }
}
