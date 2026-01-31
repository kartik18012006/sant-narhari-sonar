import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

/// Business Registration form — after paying ₹201. "List your business in the Sonar community directory."
class BusinessRegistrationScreen extends StatefulWidget {
  const BusinessRegistrationScreen({super.key});

  @override
  State<BusinessRegistrationScreen> createState() => _BusinessRegistrationScreenState();
}

class _BusinessRegistrationScreenState extends State<BusinessRegistrationScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _otherSubcasteController = TextEditingController();
  final _otherPlaceController = TextEditingController();
  final _otherBusinessNatureController = TextEditingController();
  final _passportController = TextEditingController();
  final _panCardController = TextEditingController();
  String? _subcaste;
  String? _place;
  String? _businessNature;
  bool _loading = false;

  static bool _isOther(String? v) => v != null && (v == 'Other' || v.contains('इतर') || v.contains('Other'));

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _otherSubcasteController.dispose();
    _otherPlaceController.dispose();
    _otherBusinessNatureController.dispose();
    _passportController.dispose();
    _panCardController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter business name')),
      );
      return;
    }
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      final profile = await FirestoreService.instance.getUserProfile(user.uid);
      await FirestoreService.instance.addBusiness(
        userId: user.uid,
        businessName: name,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        contact: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        subcaste: _isOther(_subcaste) && _otherSubcasteController.text.trim().isNotEmpty
            ? _otherSubcasteController.text.trim()
            : _subcaste,
        place: _isOther(_place) && _otherPlaceController.text.trim().isNotEmpty
            ? _otherPlaceController.text.trim()
            : _place,
        businessNature: _isOther(_businessNature) && _otherBusinessNatureController.text.trim().isNotEmpty
            ? _otherBusinessNatureController.text.trim()
            : _businessNature,
        createdBy: profile?['displayName'] as String? ?? user.displayName,
        passport: _passportController.text.trim().isEmpty ? null : _passportController.text.trim(),
        panCard: _panCardController.text.trim().isEmpty ? null : _panCardController.text.trim(),
      );
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business registered successfully.'),
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
          'Business Registration / व्यवसाय नोंदणी',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'List your business in the Sonar community directory.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            _label('Business Name *'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Business name'),
            ),
            const SizedBox(height: 16),
            _dropdown('Subcaste / पोटजात', _subcaste, AppTheme.subcasteOptions, (v) => setState(() => _subcaste = v)),
            if (_isOther(_subcaste)) ...[
              const SizedBox(height: 12),
              _otherField('Please specify subcaste / कृपया पोटजात निर्दिष्ट करा', _otherSubcasteController),
            ],
            const SizedBox(height: 16),
            _dropdown('Place / स्थान', _place, AppTheme.businessPlaceOptions, (v) => setState(() => _place = v)),
            if (_isOther(_place)) ...[
              const SizedBox(height: 12),
              _otherField('Please specify place / कृपया स्थान निर्दिष्ट करा', _otherPlaceController),
            ],
            const SizedBox(height: 16),
            _dropdown('Business Nature / व्यवसाय प्रकार', _businessNature, AppTheme.businessNatureOptions, (v) => setState(() => _businessNature = v)),
            if (_isOther(_businessNature)) ...[
              const SizedBox(height: 12),
              _otherField('Please specify business nature / कृपया व्यवसाय प्रकार निर्दिष्ट करा', _otherBusinessNatureController),
            ],
            const SizedBox(height: 16),
            _label('Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _inputDecoration('What does your business do?'),
            ),
            const SizedBox(height: 16),
            _label('Contact'),
            const SizedBox(height: 8),
            TextField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Phone or email'),
            ),
            const SizedBox(height: 16),
            _label('Address'),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: _inputDecoration('Address'),
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
                    : const Text('Submit Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _otherField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      decoration: _inputDecoration(hint),
    );
  }

  Widget _dropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (value == null || value.isEmpty) ? null : value,
              isExpanded: true,
              hint: Text('Select... / निवडा...', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
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
