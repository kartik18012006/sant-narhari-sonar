import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

/// Family Directory Registration form — after paying ₹101. "Family Directory Registration", "Family Details".
class FamilyDirectoryRegistrationScreen extends StatefulWidget {
  const FamilyDirectoryRegistrationScreen({super.key});

  @override
  State<FamilyDirectoryRegistrationScreen> createState() => _FamilyDirectoryRegistrationScreenState();
}

class _FamilyDirectoryRegistrationScreenState extends State<FamilyDirectoryRegistrationScreen> {
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _villageController = TextEditingController();
  final _contactController = TextEditingController();
  final _passportController = TextEditingController();
  final _panCardController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _villageController.dispose();
    _contactController.dispose();
    _passportController.dispose();
    _panCardController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name')),
      );
      return;
    }
    final contact = _contactController.text.trim();
    if (contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number of the family member')),
      );
      return;
    }
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      final profile = await FirestoreService.instance.getUserProfile(user.uid);
      await FirestoreService.instance.addFamilyDirectoryEntry(
        userId: user.uid,
        name: name,
        relation: _relationController.text.trim().isEmpty ? null : _relationController.text.trim(),
        village: _villageController.text.trim().isEmpty ? null : _villageController.text.trim(),
        contact: contact,
        createdBy: profile?['displayName'] as String? ?? user.displayName,
        passport: _passportController.text.trim().isEmpty ? null : _passportController.text.trim(),
        panCard: _panCardController.text.trim().isEmpty ? null : _panCardController.text.trim(),
      );
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Family directory entry added successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
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
        title: const Text(
          'Family Directory Registration / कुटुंब निर्देशिका नोंदणी',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Family Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 20),
            _label('Name *'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Name'),
            ),
            const SizedBox(height: 16),
            _label('Relation'),
            const SizedBox(height: 8),
            TextField(
              controller: _relationController,
              decoration: _inputDecoration('e.g. Father, Mother, Sibling'),
            ),
            const SizedBox(height: 16),
            _label('Village / City'),
            const SizedBox(height: 8),
            TextField(
              controller: _villageController,
              decoration: _inputDecoration('Village or city'),
            ),
            const SizedBox(height: 16),
            _label('Phone number of family member * / कुटुंबातील सदस्याचा फोन नंबर *'),
            const SizedBox(height: 8),
            TextField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('e.g. 9876543210'),
            ),
            const SizedBox(height: 16),
            _label('Passport (optional) / पासपोर्ट (ऐच्छिक)'),
            const SizedBox(height: 8),
            TextField(
              controller: _passportController,
              decoration: _inputDecoration('Passport number'),
            ),
            const SizedBox(height: 16),
            _label('Pan Card (optional) / पॅन कार्ड (ऐच्छिक)'),
            const SizedBox(height: 8),
            TextField(
              controller: _panCardController,
              decoration: _inputDecoration('Pan Card number'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: AppTheme.buttonHeight,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
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
                    : const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
