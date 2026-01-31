import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';
import 'admin_dashboard_screen.dart';

/// Admin Login: Enter admin credentials to access panel.
/// After sign-in, checks Firestore users/{uid}.isAdmin; only then opens Admin Dashboard.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _checkedAutoAdmin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryContinueAsAdmin());
  }

  /// If user is already signed in and is admin, go straight to Admin Dashboard.
  Future<void> _tryContinueAsAdmin() async {
    if (_checkedAutoAdmin) return;
    _checkedAutoAdmin = true;
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null || !mounted) return;
    setState(() => _loading = true);
    try {
      final isAdmin = await FirestoreService.instance.isAdmin(user.uid);
      if (!mounted) return;
      setState(() => _loading = false);
      if (isAdmin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter admin email and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuthService.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = FirebaseAuthService.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _error = 'Login failed.');
        return;
      }
      final isAdmin = await FirestoreService.instance.isAdmin(user.uid);
      if (!mounted) return;
      if (!isAdmin) {
        await FirebaseAuthService.instance.signOut();
        setState(() {
          _loading = false;
          _error = 'Admin access is restricted. Contact the system administrator if you need access.';
        });
        return;
      }
      setState(() => _loading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

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
          'Admin Login',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'Enter admin credentials to access panel.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Admin Email',
                hintText: 'Enter admin email',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Admin Password',
                hintText: 'Enter admin password',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: AppTheme.buttonHeight,
              child: FilledButton(
                onPressed: _loading ? null : _login,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Admin Login',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
