import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/language_service.dart';
import 'admin/admin_login_screen.dart';

/// Settings screen: App Language (English/Marathi), Admin Panel (if admin). Matches final APK.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LanguageService _lang = LanguageService.instance;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isAdmin = false);
      return;
    }
    try {
      final isAdmin = await FirestoreService.instance.isAdmin(user.uid);
      if (mounted) setState(() => _isAdmin = isAdmin);
    } catch (_) {
      if (mounted) setState(() => _isAdmin = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) {
        final isMarathi = _lang.isMarathi;
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
              _lang.pick('Settings', 'सेटिंग्ज'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              if (_isAdmin) ...[
                _SettingsTile(
                  icon: Icons.admin_panel_settings,
                  title: _lang.pick('Admin Panel', 'व्यवस्थापक पॅनेल'),
                  subtitle: _lang.pick('Manage users, content & feedback', 'वापरकर्ते, सामग्री आणि अभिप्राय व्यवस्थापित करा'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                  ).then((_) {
                    if (mounted) _loadAdmin();
                  }),
                ),
                const SizedBox(height: 12),
              ],
              _LanguageTile(isMarathi: isMarathi),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.gold, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}

/// App Language row: English | [Switch] | Marathi. Toggle switches language and persists.
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.isMarathi});

  final bool isMarathi;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.language, color: AppTheme.gold, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Language',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isMarathi ? 'मराठी' : 'English',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Text('English', style: TextStyle(fontSize: 12, color: isMarathi ? Colors.grey : AppTheme.gold, fontWeight: isMarathi ? FontWeight.normal : FontWeight.w600)),
            Switch(
              value: isMarathi,
              onChanged: (value) async {
                await LanguageService.instance.setLanguage(value ? LanguageService.mr : LanguageService.en);
              },
              activeTrackColor: AppTheme.gold.withValues(alpha: 0.5),
              activeThumbColor: AppTheme.gold,
            ),
            Text('मराठी', style: TextStyle(fontSize: 12, color: isMarathi ? AppTheme.gold : Colors.grey, fontWeight: isMarathi ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

