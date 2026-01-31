import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/firestore_service.dart';

/// Register as Social Worker — form with photo, personal info, address, professional details. Matches APK exactly.
class RegisterSocialWorkerScreen extends StatefulWidget {
  const RegisterSocialWorkerScreen({super.key});

  @override
  State<RegisterSocialWorkerScreen> createState() => _RegisterSocialWorkerScreenState();
}

class _RegisterSocialWorkerScreenState extends State<RegisterSocialWorkerScreen> {

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _yearsController = TextEditingController(text: '0');
  final _specializationController = TextEditingController();
  final _organizationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _otherSubcasteController = TextEditingController();
  final _passportController = TextEditingController();
  final _panCardController = TextEditingController();

  String? _subcaste;
  DateTime? _dateOfBirth;
  String? _dobError;
  String? _photoUrl;
  bool _uploadingPhoto = false;

  static bool _isOther(String? v) => v != null && (v == 'Other' || v.contains('इतर') || v.contains('Other'));

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _yearsController.dispose();
    _specializationController.dispose();
    _organizationController.dispose();
    _descriptionController.dispose();
    _otherSubcasteController.dispose();
    _passportController.dispose();
    _panCardController.dispose();
    super.dispose();
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
          'Register as Social Worker / सामाजिक कार्यकर्ता',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Photo upload
              _sectionLabel('Photo / फोटो'),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _uploadingPhoto ? null : _onPhotoTap,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _uploadingPhoto
                        ? const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _photoUrl != null
                            ? Image.network(
                                _photoUrl!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                                errorBuilder: (_, __, ___) => _photoPlaceholder(),
                              )
                            : _photoPlaceholder(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Personal Information
              _sectionLabel('Personal Information / वैयक्तिक माहिती', icon: Icons.person_outline),
              const SizedBox(height: 12),
              _textField(
                label: 'Full Name / पूर्ण नाव',
                hint: 'Enter full name',
                controller: _fullNameController,
              ),
              const SizedBox(height: 14),
              _dropdown(
                label: 'Sub-caste / पोटजात',
                value: _subcaste,
                hint: 'Select sub-caste',
                items: AppTheme.subcasteOptions,
                onChanged: (v) => setState(() => _subcaste = v),
              ),
              if (_isOther(_subcaste)) ...[
                const SizedBox(height: 12),
                _otherField('Please specify subcaste / कृपया पोटजात निर्दिष्ट करा', _otherSubcasteController),
              ],
              const SizedBox(height: 14),
              _dateOfBirthField(),
              const SizedBox(height: 14),
              _textField(
                label: 'Mobile Number / मोबाइल नंबर',
                hint: '',
                controller: _mobileController,
                prefix: '+91 ',
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
              const SizedBox(height: 14),
              _textField(
                label: 'Email ID / ईमेल आयडी',
                hint: 'Enter email id',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _sectionLabel('Residential Address / राहण्याचा पत्ता'),
              const SizedBox(height: 10),
              _textField(
                label: '',
                hint: 'Enter residential address',
                controller: _addressController,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              // Professional Details
              _sectionLabel('Professional Details / व्यावसायिक तपशील'),
              const SizedBox(height: 12),
              _yearsOfExperienceField(),
              const SizedBox(height: 14),
              _textField(
                label: 'Specialization / विशेषीकरण',
                hint: 'e.g., Community Development, Education...',
                controller: _specializationController,
              ),
              const SizedBox(height: 14),
              _textField(
                label: 'Organization / संस्था',
                hint: 'Enter organization',
                controller: _organizationController,
              ),
              const SizedBox(height: 14),
              _textField(
                label: 'Description / वर्णन',
                hint: 'Describe your work and achievements.',
                controller: _descriptionController,
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              _textField(
                label: 'Passport (optional) / पासपोर्ट (ऐच्छिक)',
                hint: 'Passport number',
                controller: _passportController,
              ),
              const SizedBox(height: 14),
              _textField(
                label: 'Pan Card (optional) / पॅन कार्ड (ऐच्छिक)',
                hint: 'Pan Card number',
                controller: _panCardController,
              ),
              const SizedBox(height: 28),
              // Back and Submit
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _onSubmit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                        ),
                      ),
                      child: const Text('Submit / सामिट करा'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: AppTheme.gold),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? prefix,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: maxLength == 10 ? [FilteringTextInputFormatter.digitsOnly] : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _otherField(String labelAndHint, TextEditingController controller) {
    return _textField(
      label: labelAndHint,
      hint: labelAndHint,
      controller: controller,
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
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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

  Widget _dateOfBirthField() {
    final hasError = _dobError != null && _dobError!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth / जन्मतारीख *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _dateOfBirth ?? DateTime(1990),
              firstDate: DateTime(1920),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _dateOfBirth = date;
                _dobError = null;
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: 'dd/mm/yyyy',
              suffixIcon: Icon(Icons.calendar_today, size: 22, color: Colors.grey.shade600),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.grey.shade300,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            child: Text(
              _dateOfBirth != null
                  ? '${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.year}'
                  : '',
              style: TextStyle(
                fontSize: 16,
                color: _dateOfBirth != null ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            _dobError!,
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
      ],
    );
  }

  Widget _yearsOfExperienceField() {
    int years = int.tryParse(_yearsController.text) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Years of Experience / अनुभव वर्षे',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            IconButton.filled(
              onPressed: () {
                if (years > 0) {
                  setState(() {
                    years--;
                    _yearsController.text = '$years';
                  });
                }
              },
              icon: const Icon(Icons.remove, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _yearsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Enter years of experience',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: () {
                setState(() {
                  years++;
                  _yearsController.text = '$years';
                });
              },
              icon: const Icon(Icons.add, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
                foregroundColor: AppTheme.gold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _photoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 36, color: Colors.grey.shade600),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Click here to upload your photo (Max 1MB allowed)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Future<void> _onPhotoTap() async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to upload photo')));
      return;
    }
    final picker = ImagePicker();
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
      final xFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
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
      final storagePath = FirebaseStorageService.instance.uniquePath('social_workers/${user.uid}', extension: 'jpg');
      final url = await FirebaseStorageService.instance.uploadImage(bytes: bytes, path: storagePath);
      if (!mounted) return;
      setState(() {
        _uploadingPhoto = false;
        if (url != null) _photoUrl = url;
      });
      if (url != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded. It will be saved with your registration.'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Please try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _onSubmit() async {
    _dobError = null;
    if (_dateOfBirth == null) {
      setState(() => _dobError = 'This field is required');
      return;
    }
    final name = _fullNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter full name')));
      return;
    }
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in')));
      return;
    }
    final profile = await FirestoreService.instance.getUserProfile(user.uid);
    final createdBy = profile?['displayName'] as String? ?? user.displayName ?? user.email ?? user.phoneNumber;
    final years = int.tryParse(_yearsController.text);
    final dobStr = _dateOfBirth != null
        ? '${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.year}'
        : null;
    try {
      await FirestoreService.instance.addSocialWorker(
        userId: user.uid,
        name: name,
        phone: _mobileController.text.trim().isEmpty ? null : _mobileController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        createdBy: createdBy,
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        subcaste: _isOther(_subcaste) && _otherSubcasteController.text.trim().isNotEmpty
            ? _otherSubcasteController.text.trim()
            : _subcaste,
        dateOfBirth: dobStr,
        yearsOfExperience: years,
        specialization: _specializationController.text.trim().isEmpty ? null : _specializationController.text.trim(),
        organization: _organizationController.text.trim().isEmpty ? null : _organizationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        photoUrl: _photoUrl,
        passport: _passportController.text.trim().isEmpty ? null : _passportController.text.trim(),
        panCard: _panCardController.text.trim().isEmpty ? null : _panCardController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration submitted. Admin may review before publishing.'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(); // Register form
      Navigator.of(context).pop(); // Terms -> back to Social Workers
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }
}
