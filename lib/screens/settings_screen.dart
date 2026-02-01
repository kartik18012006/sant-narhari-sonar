import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/language_service.dart';
import 'admin/admin_login_screen.dart';
import 'family_directory_registration_screen.dart';
import 'matrimony_registration_screen.dart';
import 'business_registration_screen.dart';
import 'register_social_worker_screen.dart';
import 'matrimony_profile_detail_screen.dart';

/// Settings screen: App Language (English/Marathi), Admin Panel (if admin), Your Registrations. Matches final APK.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LanguageService _lang = LanguageService.instance;
  bool _isAdmin = false;
  bool _loadingRegistrations = true;
  bool _hasFamilyDirectory = false;
  bool _hasMatrimony = false;
  bool _hasBusiness = false;
  bool _hasSocialWorker = false;
  Map<String, dynamic>? _matrimonyData;

  @override
  void initState() {
    super.initState();
    _loadAdmin();
    _loadRegistrations();
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

  Future<void> _loadRegistrations() async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loadingRegistrations = false);
      return;
    }
    try {
      final familyDir = await FirestoreService.instance.getUserFamilyDirectoryRegistration(user.uid);
      final matrimony = await FirestoreService.instance.getUserMatrimonyRegistration(user.uid);
      final business = await FirestoreService.instance.getUserBusinessRegistration(user.uid);
      final socialWorker = await FirestoreService.instance.getUserSocialWorkerRegistration(user.uid);
      if (mounted) {
        setState(() {
          _hasFamilyDirectory = familyDir != null;
          _hasMatrimony = matrimony != null;
          _hasBusiness = business != null;
          _hasSocialWorker = socialWorker != null;
          _matrimonyData = matrimony;
          _loadingRegistrations = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingRegistrations = false);
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
              // Your Registrations Section
              Text(
                _lang.pick('Your registrations', 'तुमच्या नोंदण्या'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                ),
                child: Column(
                  children: [
                    _RegistrationTile(
                      title: _lang.pick('Family Directory', 'कुटुंब निर्देशिका'),
                      isRegistered: _hasFamilyDirectory,
                      loading: _loadingRegistrations,
                      onTap: _hasFamilyDirectory
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const FamilyDirectoryRegistrationScreen(),
                                ),
                              ).then((_) => _loadRegistrations());
                            }
                          : null,
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _RegistrationTile(
                      title: _lang.pick('Matrimony (Bride/Groom)', 'विवाह (वर/वधू)'),
                      isRegistered: _hasMatrimony,
                      loading: _loadingRegistrations,
                      onTap: _hasMatrimony
                          ? () {
                              if (_matrimonyData != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MatrimonyProfileDetailScreen(profile: _matrimonyData!),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const MatrimonyRegistrationScreen(isGroom: true),
                                  ),
                                ).then((_) => _loadRegistrations());
                              }
                            }
                          : null,
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _RegistrationTile(
                      title: _lang.pick('Business', 'व्यापार'),
                      isRegistered: _hasBusiness,
                      loading: _loadingRegistrations,
                      onTap: _hasBusiness
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const BusinessRegistrationScreen(),
                                ),
                              ).then((_) => _loadRegistrations());
                            }
                          : null,
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _RegistrationTile(
                      title: _lang.pick('Social Worker', 'सामाजिक कार्यकर्ता'),
                      isRegistered: _hasSocialWorker,
                      loading: _loadingRegistrations,
                      onTap: _hasSocialWorker
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterSocialWorkerScreen(),
                                ),
                              ).then((_) => _loadRegistrations());
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _lang.pick('Account', 'खाते'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
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

/// Registration tile in "Your registrations" section.
class _RegistrationTile extends StatelessWidget {
  const _RegistrationTile({
    required this.title,
    required this.isRegistered,
    required this.loading,
    this.onTap,
  });

  final String title;
  final bool isRegistered;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              if (loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.gold),
                )
              else
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isRegistered ? AppTheme.gold : Colors.grey.shade300,
                      width: 2,
                    ),
                    color: isRegistered ? AppTheme.gold : Colors.transparent,
                  ),
                  child: isRegistered
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isRegistered ? FontWeight.w600 : FontWeight.normal,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              if (isRegistered && onTap != null)
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade500)
              else if (!isRegistered)
                Text(
                  '—',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                ),
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

