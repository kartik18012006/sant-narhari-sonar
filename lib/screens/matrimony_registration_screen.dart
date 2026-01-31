import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/firestore_service.dart';

/// Matrimony Registration form — after paying ₹2100. "Register as Groom" or "Register as Bride".
/// "Final Step: Complete payment to submit your matrimonial profile."
class MatrimonyRegistrationScreen extends StatefulWidget {
  const MatrimonyRegistrationScreen({super.key, required this.isGroom});

  final bool isGroom;

  @override
  State<MatrimonyRegistrationScreen> createState() => _MatrimonyRegistrationScreenState();
}

/// Holds controllers for one family member (name, number, relation, age).
class _FamilyMemberEntry {
  final TextEditingController name = TextEditingController();
  final TextEditingController number = TextEditingController();
  final TextEditingController relation = TextEditingController();
  final TextEditingController age = TextEditingController();

  void dispose() {
    name.dispose();
    number.dispose();
    relation.dispose();
    age.dispose();
  }

  Map<String, String> toMap() => {
        'name': name.text.trim(),
        'number': number.text.trim(),
        'relation': relation.text.trim(),
        'age': age.text.trim(),
      };
}

class _MatrimonyRegistrationScreenState extends State<MatrimonyRegistrationScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _educationController = TextEditingController();
  final _occupationController = TextEditingController();
  final _cityController = TextEditingController();
  final _otherSubcasteController = TextEditingController();
  final _passportController = TextEditingController();
  final _panCardController = TextEditingController();
  final List<_FamilyMemberEntry> _familyMembers = [];
  String? _subcaste;
  String? _maritalStatus;
  bool _loading = false;
  String? _photoUrl;
  bool _uploadingPhoto = false;

  static bool _isOther(String? v) => v != null && (v == 'Other' || v.contains('इतर') || v.contains('Other'));

  String get _type => widget.isGroom ? 'groom' : 'bride';
  String get _title => widget.isGroom ? 'Register as Groom / वर म्हणून नोंदणी' : 'Register as Bride / वधू म्हणून नोंदणी';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _educationController.dispose();
    _occupationController.dispose();
    _cityController.dispose();
    _otherSubcasteController.dispose();
    _passportController.dispose();
    _panCardController.dispose();
    for (final e in _familyMembers) e.dispose();
    super.dispose();
  }

  void _addFamilyMember() {
    setState(() => _familyMembers.add(_FamilyMemberEntry()));
  }

  void _removeFamilyMember(int index) {
    _familyMembers[index].dispose();
    setState(() => _familyMembers.removeAt(index));
  }

  Widget _matrimonyPhotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade500),
        const SizedBox(height: 4),
        Text(
          'Tap to add photo',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _pickPhoto() async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (xFile == null || !mounted) return;
      final bytes = await xFile.readAsBytes();
      if (bytes.length > FirebaseStorageService.maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image must be under 1MB. Please choose a smaller image.')),
          );
        }
        return;
      }
      setState(() => _uploadingPhoto = true);
      final path = FirebaseStorageService.instance.uniquePath('matrimony/${user.uid}', extension: 'jpg');
      final url = await FirebaseStorageService.instance.uploadImage(bytes: bytes, path: path);
      if (!mounted) return;
      setState(() {
        _uploadingPhoto = false;
        if (url != null) _photoUrl = url;
      });
      if (url != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded. It will be saved with your profile.'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed. Please try again.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name')),
      );
      return;
    }
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      final profile = await FirestoreService.instance.getUserProfile(user.uid);
      await FirestoreService.instance.addMatrimonyProfile(
        userId: user.uid,
        type: _type,
        name: name,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        education: _educationController.text.trim().isEmpty ? null : _educationController.text.trim(),
        occupation: _occupationController.text.trim().isEmpty ? null : _occupationController.text.trim(),
        subcaste: _isOther(_subcaste) && _otherSubcasteController.text.trim().isNotEmpty
            ? _otherSubcasteController.text.trim()
            : _subcaste,
        maritalStatus: _maritalStatus,
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        familyMembers: _familyMembers
            .map((e) => e.toMap())
            .where((m) => (m['name'] ?? '').isNotEmpty)
            .map((m) => {
                  'name': m['name']!,
                  'number': m['number'] ?? '',
                  'relation': m['relation'] ?? '',
                  'age': m['age'] ?? '',
                })
            .toList(),
        createdBy: profile?['displayName'] as String? ?? user.displayName,
        photoUrl: _photoUrl,
        passport: _passportController.text.trim().isEmpty ? null : _passportController.text.trim(),
        panCard: _panCardController.text.trim().isEmpty ? null : _panCardController.text.trim(),
      );
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Matrimonial profile submitted. Admin may review before publishing.'),
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
        title: Text(
          _title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create a detailed matrimonial profile',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            _label('Profile photo (optional) / प्रोफाइल फोटो (ऐच्छिक)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _uploadingPhoto || _loading ? null : _pickPhoto,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _photoUrl != null && _photoUrl!.isNotEmpty
                      ? Image.network(
                          _photoUrl!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorBuilder: (_, __, ___) => _matrimonyPhotoPlaceholder(),
                        )
                      : _matrimonyPhotoPlaceholder(),
                ),
              ),
            ),
            if (_uploadingPhoto)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Uploading...', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ),
            const SizedBox(height: 24),
            _label('Name *'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Full name'),
            ),
            const SizedBox(height: 16),
            _label('Phone'),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Phone number'),
            ),
            const SizedBox(height: 16),
            _label('Email'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Email'),
            ),
            const SizedBox(height: 16),
            _label('Education'),
            const SizedBox(height: 8),
            TextField(
              controller: _educationController,
              decoration: _inputDecoration('Education'),
            ),
            const SizedBox(height: 16),
            _label('Occupation'),
            const SizedBox(height: 8),
            TextField(
              controller: _occupationController,
              decoration: _inputDecoration('Occupation'),
            ),
            const SizedBox(height: 16),
            _dropdown(
              label: 'Marital Status / वैवाहिक स्थिती',
              value: _maritalStatus,
              hint: 'Select... / निवडा...',
              items: AppTheme.maritalStatusOptions,
              onChanged: (v) => setState(() => _maritalStatus = v),
            ),
            const SizedBox(height: 16),
            _dropdown(
              label: 'Sub Caste / पोटजात',
              value: _subcaste,
              hint: 'Select... / निवडा...',
              items: AppTheme.subcasteOptions,
              onChanged: (v) => setState(() => _subcaste = v),
            ),
            if (_isOther(_subcaste)) ...[
              const SizedBox(height: 12),
              _otherField('Please specify subcaste / कृपया पोटजात निर्दिष्ट करा', _otherSubcasteController),
            ],
            const SizedBox(height: 16),
            _label('City / शहर'),
            const SizedBox(height: 8),
            TextField(
              controller: _cityController,
              decoration: _inputDecoration('City'),
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Family Details / कौटुंबिक माहिती',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                ),
                TextButton.icon(
                  onPressed: _addFamilyMember,
                  icon: const Icon(Icons.add, size: 20, color: AppTheme.gold),
                  label: Text(
                    'Add member',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.gold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(_familyMembers.length, (i) {
              final e = _familyMembers[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Member ${i + 1}',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                          ),
                          IconButton(
                            onPressed: () => _removeFamilyMember(i),
                            icon: Icon(Icons.remove_circle_outline, size: 22, color: Colors.grey.shade600),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: e.name,
                        onChanged: (_) => setState(() {}),
                        decoration: _inputDecoration('Name / नाव'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: e.number,
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration('Number / नंबर'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: e.relation,
                        onChanged: (_) => setState(() {}),
                        decoration: _inputDecoration('Relation / नाते (e.g. Father, Mother)'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: e.age,
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Age / वय'),
                      ),
                    ],
                  ),
                ),
              );
            }),
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
                    : const Text('Submit Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _otherField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      decoration: _inputDecoration(hint),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
        ),
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
              hint: Text(hint, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
