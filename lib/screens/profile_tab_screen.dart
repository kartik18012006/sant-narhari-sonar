import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/language_service.dart';
import 'admin/admin_login_screen.dart';
import 'profile_detail_screen.dart';
import 'settings_screen.dart';

/// Profile tab: user info, About Me, Settings, Admin Panel (if admin), Sign Out.
/// Matches APK ProfileScreen structure and behavior.
class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _isAdmin = false;
  bool _isSuspended = false;
  bool _hasFamilyDir = false;
  bool _hasMatrimony = false;
  bool _hasBusiness = false;
  bool _hasSocialWorker = false;
  final LanguageService _lang = LanguageService.instance;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Safe first letter for avatar; never throws on empty string.
  static String _initialForProfile(dynamic displayName, dynamic user) {
    final raw = displayName ?? user?.email ?? user?.phoneNumber ?? 'U';
    final s = raw.toString().trim();
    if (s.isEmpty) return 'U';
    return s.substring(0, 1).toUpperCase();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      await FirebaseAuthService.instance.reloadUser();
      final freshUser = FirebaseAuthService.instance.currentUser;
      if (freshUser == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final profile = await FirestoreService.instance.getUserProfile(freshUser.uid);
      final isAdmin = await FirestoreService.instance.isAdmin(freshUser.uid);
      final isSuspended = profile?['isSuspended'] == true;
      final hasFamilyDir = await FirestoreService.instance.hasUserRegisteredFamilyDirectory(freshUser.uid);
      final hasMatrimony = await FirestoreService.instance.hasUserRegisteredMatrimony(freshUser.uid);
      final hasBusiness = await FirestoreService.instance.hasUserRegisteredBusiness(freshUser.uid);
      final hasSocialWorker = await FirestoreService.instance.hasUserRegisteredSocialWorker(freshUser.uid);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isAdmin = isAdmin;
          _isSuspended = isSuspended;
          _hasFamilyDir = hasFamilyDir;
          _hasMatrimony = hasMatrimony;
          _hasBusiness = hasBusiness;
          _hasSocialWorker = hasSocialWorker;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _profile = null;
          _isAdmin = false;
          _isSuspended = false;
          _hasFamilyDir = false;
          _hasMatrimony = false;
          _hasBusiness = false;
          _hasSocialWorker = false;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuthService.instance.currentUser;
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              _lang.pick('Profile', 'प्रोफाइल'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                if (_isSuspended) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _lang.pick('Your account is suspended. Contact support for assistance.', 'तुमचे खाते निलंबित आहे. सहाय्यासाठी संपर्क करा.'),
                            style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (user != null &&
                    user.providerData.any((p) => p.providerId == 'password') &&
                    (user.email ?? '').isNotEmpty &&
                    !user.emailVerified) ...[
                  _EmailVerificationBanner(onResend: _loadProfile),
                  const SizedBox(height: 16),
                ],
                // User info card (from Firebase)
                if (user != null) ...[
                  Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
                      child: Text(
                        _initialForProfile(_profile?['displayName'], user),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _loading
                          ? const SizedBox(
                              height: 40,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profile?['displayName'] ?? user.displayName ?? user.email ?? user.phoneNumber ?? 'User',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (user.email != null && (user.email ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email!,
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                  ),
                                ],
                                if (user.phoneNumber != null && (user.phoneNumber ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    user.phoneNumber!,
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Your registrations (Explore features)
            if (user != null) ...[
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
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _RegistrationRow(
                      label: _lang.pick('Family Directory', 'कुटुंब निर्देशिका'),
                      registered: _hasFamilyDir,
                      registeredLabel: _lang.pick('Registered', 'नोंदणी झाली'),
                    ),
                    const Divider(height: 24),
                    _RegistrationRow(
                      label: _lang.pick('Matrimony (Bride/Groom)', 'विवाह (वर/वधू)'),
                      registered: _hasMatrimony,
                      registeredLabel: _lang.pick('Registered', 'नोंदणी झाली'),
                    ),
                    const Divider(height: 24),
                    _RegistrationRow(
                      label: _lang.pick('Business', 'व्यवसाय'),
                      registered: _hasBusiness,
                      registeredLabel: _lang.pick('Registered', 'नोंदणी झाली'),
                    ),
                    const Divider(height: 24),
                    _RegistrationRow(
                      label: _lang.pick('Social Worker', 'सामाजिक कार्यकर्ता'),
                      registered: _hasSocialWorker,
                      registeredLabel: _lang.pick('Registered', 'नोंदणी झाली'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Account: About Me, Settings, App Goals, Feedback, Admin Panel
            Text(
              _lang.pick('Account', 'खाते'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            _ProfileTile(
              icon: Icons.person_outline,
              title: _lang.pick('About Me', 'माझ्याबद्दल'),
              subtitle: _lang.pick('Edit your profile', 'तुमची प्रोफाइल संपादित करा'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileDetailScreen()),
              ).then((result) {
                if (mounted && result == true) _loadProfile();
              }),
            ),
            const SizedBox(height: 12),
            _ProfileTile(
              icon: Icons.settings_outlined,
              title: _lang.pick('Settings', 'सेटिंग्ज'),
              subtitle: _lang.pick('Notifications, Terms', 'सूचना, नियम'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            if (_isAdmin) ...[
              const SizedBox(height: 12),
              _ProfileTile(
                icon: Icons.admin_panel_settings,
                title: _lang.pick('Admin Panel', 'व्यवस्थापक पॅनेल'),
                subtitle: _lang.pick('Manage users, content & feedback', 'वापरकर्ते, सामग्री आणि अभिप्राय व्यवस्थापित करा'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                ).then((_) {
                  if (mounted) _loadProfile();
                }),
              ),
            ],
            const SizedBox(height: 24),
            // Sign out
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await FirebaseAuthService.instance.signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_lang.pick('Signed out', 'साइन आउट झाले'))),
                    );
                  }
                },
                icon: Icon(Icons.logout, size: 20, color: Colors.grey.shade700),
                label: Text(
                  _lang.pick('Sign Out', 'साइन आउट'),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
        );
      },
    );
  }
}

class _RegistrationRow extends StatelessWidget {
  const _RegistrationRow({
    required this.label,
    required this.registered,
    required this.registeredLabel,
  });

  final String label;
  final bool registered;
  final String registeredLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          registered ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 22,
          color: registered ? Colors.green : Colors.grey.shade400,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Text(
          registered ? registeredLabel : '—',
          style: TextStyle(
            fontSize: 13,
            color: registered ? Colors.green.shade700 : Colors.grey.shade500,
            fontWeight: registered ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
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
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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

/// Banner shown when user signed in with email but email is not verified. Offers "Resend verification email".
class _EmailVerificationBanner extends StatefulWidget {
  const _EmailVerificationBanner({required this.onResend});

  final VoidCallback? onResend;

  @override
  State<_EmailVerificationBanner> createState() => _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<_EmailVerificationBanner> {
  bool _sending = false;

  Future<void> _resend() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await FirebaseAuthService.instance.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent. Check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onResend?.call();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send. Try again later.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mark_email_unread_outlined, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verify your email to secure your account.',
                  style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _sending ? null : _resend,
              icon: _sending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.email_outlined, size: 18, color: Colors.blue.shade700),
              label: Text(
                _sending ? 'Sending...' : 'Resend verification email',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
