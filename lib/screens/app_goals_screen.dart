import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/language_service.dart';

/// App Goals / Life Goals: "Enter your life goals..." — saved to user profile in Firestore.
class AppGoalsScreen extends StatefulWidget {
  const AppGoalsScreen({super.key});

  @override
  State<AppGoalsScreen> createState() => _AppGoalsScreenState();
}

class _AppGoalsScreenState extends State<AppGoalsScreen> {
  final _controller = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final profile = await FirestoreService.instance.getUserProfile(user.uid);
      final goals = profile?['lifeGoals'] as String? ?? '';
      if (mounted) {
        _controller.text = goals;
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      await FirestoreService.instance.setUserGoals(user.uid, _controller.text.trim());
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goals saved.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
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
          LanguageService.instance.pick('App Goals', 'आपले उद्दिष्ट'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : ListenableBuilder(
              listenable: LanguageService.instance,
              builder: (context, _) {
                final lang = LanguageService.instance;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        lang.pick('Enter your life goals...', 'तुमची जीवन उद्दिष्टे प्रविष्ट करा...'),
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _controller,
                        maxLines: 6,
                        enabled: !_saving,
                        decoration: InputDecoration(
                          hintText: lang.pick('Your goals...', 'तुमची उद्दिष्टे...'),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                            borderSide: BorderSide(color: Colors.grey.shade300),
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
                      const SizedBox(height: 20),
                      SizedBox(
                        height: AppTheme.buttonHeight,
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.gold,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  lang.pick('Save Goals', 'उद्दिष्टे जतन करा'),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
