import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/image_picker_service.dart';

/// Family Directory Registration form — comprehensive form matching screenshots exactly.
class FamilyDirectoryRegistrationScreen extends StatefulWidget {
  const FamilyDirectoryRegistrationScreen({super.key});

  @override
  State<FamilyDirectoryRegistrationScreen> createState() => _FamilyDirectoryRegistrationScreenState();
}

/// Holds controllers for one family member (name, relation, age, contact).
class _FamilyMemberEntry {
  final TextEditingController name = TextEditingController();
  final TextEditingController relation = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController contact = TextEditingController();

  void dispose() {
    name.dispose();
    relation.dispose();
    age.dispose();
    contact.dispose();
  }

  Map<String, String> toMap() => {
        'name': name.text.trim(),
        'relation': relation.text.trim(),
        'age': age.text.trim(),
        'contact': contact.text.trim(),
      };
}

class _FamilyDirectoryRegistrationScreenState extends State<FamilyDirectoryRegistrationScreen> {
  // Personal Information
  final _fullNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  // Contact Details
  final _mobileController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();

  // Address Details
  final _permanentAddressController = TextEditingController();
  final _permanentPincodeController = TextEditingController();
  final _permanentVillageCityController = TextEditingController();
  final _permanentTalukaController = TextEditingController();
  final _permanentDistrictController = TextEditingController();
  final _permanentStateController = TextEditingController();
  final _permanentCountryController = TextEditingController();

  // Other Information
  final _emergencyContactPersonController = TextEditingController();
  final _emergencyContactNumberController = TextEditingController();

  // Dropdown values
  String? _subcaste;
  String? _gender;
  String? _bloodGroup;
  String? _diet;

  // Custom "Other" values
  final _subcasteOtherController = TextEditingController();
  final _genderOtherController = TextEditingController();

  // Family Members
  final List<_FamilyMemberEntry> _familyMembers = [];

  // Document images
  String? _aadhaarImageUrl;
  String? _panCardImageUrl;
  bool _uploadingAadhaar = false;
  bool _uploadingPanCard = false;

  // Photo
  String? _photoUrl;
  bool _uploadingPhoto = false;
  bool _loading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _mobileController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _permanentAddressController.dispose();
    _permanentPincodeController.dispose();
    _permanentVillageCityController.dispose();
    _permanentTalukaController.dispose();
    _permanentDistrictController.dispose();
    _permanentStateController.dispose();
    _permanentCountryController.dispose();
    _emergencyContactPersonController.dispose();
    _emergencyContactNumberController.dispose();
    _subcasteOtherController.dispose();
    _genderOtherController.dispose();
    for (final e in _familyMembers) e.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.gold),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<String?> _uploadDocument(String documentType) async {
    return await ImagePickerService.instance.pickAndUploadImage(
      context: context,
      storagePath: 'family_directory/${FirebaseAuthService.instance.currentUser?.uid ?? 'unknown'}/documents/$documentType',
      maxWidth: 1920,
      maxHeight: 1080,
      successMessage: 'Document uploaded successfully.',
      errorMessage: 'Upload failed. Please try again.',
    );
  }

  Future<void> _pickPhoto() async {
    setState(() => _uploadingPhoto = true);
    try {
      final url = await ImagePickerService.instance.pickAndUploadImage(
        context: context,
        storagePath: 'family_directory/${FirebaseAuthService.instance.currentUser?.uid ?? 'unknown'}',
        maxWidth: 1024,
        maxHeight: 1024,
        successMessage: 'Photo uploaded successfully.',
      );
      if (!mounted) return;
      setState(() {
        _uploadingPhoto = false;
        if (url != null) _photoUrl = url;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addFamilyMember() {
    setState(() => _familyMembers.add(_FamilyMemberEntry()));
  }

  void _removeFamilyMember(int index) {
    _familyMembers[index].dispose();
    setState(() => _familyMembers.removeAt(index));
  }

  Future<void> _onSubmit() async {
    final name = _fullNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter full name')),
      );
      return;
    }
    if (_aadhaarImageUrl == null || _aadhaarImageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload Aadhaar Card')),
      );
      return;
    }
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in')));
      return;
    }
    final profile = await FirestoreService.instance.getUserProfile(user.uid);
    final createdBy = profile?['displayName'] as String? ?? user.displayName ?? user.email ?? user.phoneNumber;
    setState(() => _loading = true);
    try {
      await FirestoreService.instance.addFamilyDirectoryEntry(
        userId: user.uid,
        name: name,
        gender: (_gender != null && (_gender!.contains('Other') || _gender!.contains('इतर'))) && _genderOtherController.text.trim().isNotEmpty
            ? _genderOtherController.text.trim()
            : _gender,
        bloodGroup: _bloodGroup,
        diet: _diet,
        subcaste: (_subcaste != null && (_subcaste!.contains('Other') || _subcaste!.contains('इतर'))) && _subcasteOtherController.text.trim().isNotEmpty
            ? _subcasteOtherController.text.trim()
            : _subcaste,
        dateOfBirth: _dateOfBirthController.text.trim().isEmpty ? null : _dateOfBirthController.text.trim(),
        phone: _mobileController.text.trim().isEmpty ? null : _mobileController.text.trim(),
        whatsappNumber: _whatsappController.text.trim().isEmpty ? null : _whatsappController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        permanentAddress: _permanentAddressController.text.trim().isEmpty ? null : _permanentAddressController.text.trim(),
        permanentPincode: _permanentPincodeController.text.trim().isEmpty ? null : _permanentPincodeController.text.trim(),
        permanentVillageCity: _permanentVillageCityController.text.trim().isEmpty ? null : _permanentVillageCityController.text.trim(),
        permanentTaluka: _permanentTalukaController.text.trim().isEmpty ? null : _permanentTalukaController.text.trim(),
        permanentDistrict: _permanentDistrictController.text.trim().isEmpty ? null : _permanentDistrictController.text.trim(),
        permanentState: _permanentStateController.text.trim().isEmpty ? null : _permanentStateController.text.trim(),
        permanentCountry: _permanentCountryController.text.trim().isEmpty ? null : _permanentCountryController.text.trim(),
        emergencyContactPerson: _emergencyContactPersonController.text.trim().isEmpty ? null : _emergencyContactPersonController.text.trim(),
        emergencyContactNumber: _emergencyContactNumberController.text.trim().isEmpty ? null : _emergencyContactNumberController.text.trim(),
        familyMembers: _familyMembers
            .map((e) => e.toMap())
            .where((m) => (m['name'] ?? '').isNotEmpty)
            .toList(),
        createdBy: createdBy,
        photoUrl: _photoUrl,
        documents: {
          'aadhaar': _aadhaarImageUrl,
          'panCard': _panCardImageUrl,
        },
      );
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Family directory entry submitted successfully. Admin may review before publishing.'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
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
            // Photo Upload
            Center(
              child: GestureDetector(
                onTap: _uploadingPhoto || _loading ? null : _pickPhoto,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.pink.shade200, width: 2, style: BorderStyle.solid),
                  ),
                  child: _uploadingPhoto
                      ? const Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _photoUrl != null && _photoUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                _photoUrl!,
                                fit: BoxFit.cover,
                                width: 150,
                                height: 150,
                                errorBuilder: (_, __, ___) => _photoPlaceholder(),
                              ),
                            )
                          : _photoPlaceholder(),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Section 1: Personal Information
            _buildSectionHeader('Personal Information / मूलभूत संपर्क माहिती', color: Colors.pink.shade100),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Full Name / पूर्ण नाव',
              controller: _fullNameController,
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Sub-caste / पोटजात',
              value: _subcaste,
              items: AppTheme.subcasteOptions,
              icon: Icons.category,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Gender / लिंग',
              value: _gender,
              items: AppTheme.genderOptions,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Blood Group / रक्तगट',
              value: _bloodGroup,
              items: AppTheme.bloodGroupOptions,
              icon: Icons.water_drop,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Date of Birth / जन्मतारीख',
              controller: _dateOfBirthController,
              icon: Icons.calendar_today,
              readOnly: true,
              onTap: _pickDateOfBirth,
              hint: 'dd/mm/yyyy',
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Diet / आहार',
              value: _diet,
              items: AppTheme.dietOptions,
              icon: Icons.restaurant,
            ),
            const SizedBox(height: 32),

            // Section 2: Contact Details
            _buildSectionHeader('Contact Details / संपर्क तपशील', color: Colors.pink.shade100, icon: Icons.phone),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Mobile Number / मोबाईल नंबर',
              controller: _mobileController,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              prefix: '+91 ',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'WhatsApp Number / व्हॉट्‌सअॅप नंबर',
              controller: _whatsappController,
              icon: Icons.chat,
              keyboardType: TextInputType.phone,
              prefix: '+91 ',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Email ID / ईमेल आयडी',
              controller: _emailController,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 32),

            // Section 3: Address Details
            _buildSectionHeader('Address Details / पत्ता तपशील', color: Colors.pink.shade100, icon: Icons.home),
            const SizedBox(height: 16),
            _buildSubSectionHeader('Permanent Address / कायमचा पत्ता'),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Address (e.g. Flat No., Landmark) / पत्ता (उदा. फ्लॅट नं., लँड मार्क)',
              controller: _permanentAddressController,
              icon: Icons.location_on,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Pincode / पिनकोड',
              controller: _permanentPincodeController,
              icon: Icons.pin,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Village/City / गाव/शहर',
              controller: _permanentVillageCityController,
              icon: Icons.location_city,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Taluka / तालुका',
              controller: _permanentTalukaController,
              icon: Icons.map,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'District / जिल्हा',
              controller: _permanentDistrictController,
              icon: Icons.location_city,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'State / राज्य',
              controller: _permanentStateController,
              icon: Icons.map,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Country / देश',
              controller: _permanentCountryController,
              icon: Icons.public,
            ),
            const SizedBox(height: 32),

            // Section 4: Family Information
            _buildSectionHeader('Family Information / कौटुंबिक माहिती', color: Colors.pink.shade100, icon: Icons.family_restroom),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _addFamilyMember,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  '+ Add Family Member / कुटुंब सदस्य जोडा',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                            'Family Member ${i + 1}',
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
                      _buildTextField(
                        label: 'Name / नाव',
                        controller: e.name,
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Relation / नाते',
                              controller: e.relation,
                              icon: Icons.people,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              label: 'Age / वय',
                              controller: e.age,
                              icon: Icons.cake,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: 'Contact / संपर्क',
                        controller: e.contact,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        prefix: '+91 ',
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),

            // Section 5: Other Information
            _buildSectionHeader('Other Information / इतर माहिती', color: Colors.pink.shade100, icon: Icons.info_outline),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Emergency Contact Person / आपत्कालीन संपर्क व्यक्ती',
              controller: _emergencyContactPersonController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Emergency Contact Number / आपत्कालीन संपर्क क्रमांक',
              controller: _emergencyContactNumberController,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              prefix: '+91 ',
            ),
            const SizedBox(height: 32),

            // Section 6: KYC & Document Upload
            _buildSectionHeader('KYC & Document Upload / केवायसी आणि कागदपत्र अपलोड', color: Colors.pink.shade100),
            const SizedBox(height: 16),
            Text(
              'Please select the documents you wish to upload for verification. / कृपया पडताळणीसाठी अपलोड करु इच्छित असलेली कागदपत्रे निवडा.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            _buildDocumentUpload(
              label: 'Aadhaar Card / आधार कार्ड',
              imageUrl: _aadhaarImageUrl,
              uploading: _uploadingAadhaar,
              required: true,
              onTap: () async {
                setState(() => _uploadingAadhaar = true);
                final url = await _uploadDocument('aadhaar');
                if (!mounted) return;
                setState(() {
                  _uploadingAadhaar = false;
                  if (url != null) _aadhaarImageUrl = url;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDocumentUpload(
              label: 'PAN Card / पॅन कार्ड (Optional)',
              imageUrl: _panCardImageUrl,
              uploading: _uploadingPanCard,
              required: false,
              onTap: () async {
                setState(() => _uploadingPanCard = true);
                final url = await _uploadDocument('pan_card');
                if (!mounted) return;
                setState(() {
                  _uploadingPanCard = false;
                  if (url != null) _panCardImageUrl = url;
                });
              },
            ),
            const SizedBox(height: 32),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade800,
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
                    onPressed: _loading ? null : _onSubmit,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
                            'Preview Entry / फॉर्मचे पूर्वावलोकन',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color ?? Colors.pink.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.pink.shade700),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? hint,
    TextInputType? keyboardType,
    String? prefix,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: keyboardType == TextInputType.phone || keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
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
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            errorStyle: const TextStyle(height: 0, fontSize: 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    IconData? icon,
  }) {
    final isOtherSelected = value != null && (value.contains('Other') || value.contains('इतर'));
    TextEditingController? otherController;
    if (label.contains('Sub-caste')) {
      otherController = _subcasteOtherController;
    } else if (label.contains('Gender')) {
      otherController = _genderOtherController;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
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
              value: value,
              isExpanded: true,
              hint: Text(
                'Select... / निवडा...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              items: [
                // First item: "Select... / निवडा..." with checkmark when no value selected
                DropdownMenuItem<String>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        size: 16,
                        color: value == null ? Colors.green : Colors.transparent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select... / निवडा...',
                        style: TextStyle(
                          fontSize: 14,
                          color: value == null ? Colors.grey.shade800 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Other items
                ...items.map((item) {
                  final isSelected = value == item;
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          size: 16,
                          color: isSelected ? Colors.green : Colors.transparent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.grey.shade900 : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (v) {
                setState(() {
                  if (label.contains('Sub-caste')) {
                    _subcaste = v;
                    if (v == null || !(v.contains('Other') || v.contains('इतर'))) {
                      _subcasteOtherController.clear();
                    }
                  } else if (label.contains('Gender')) {
                    _gender = v;
                    if (v == null || !(v.contains('Other') || v.contains('इतर'))) {
                      _genderOtherController.clear();
                    }
                  } else if (label.contains('Blood Group')) _bloodGroup = v;
                  else if (label.contains('Diet')) _diet = v;
                });
              },
              selectedItemBuilder: (context) {
                return [
                  Text(
                    value ?? 'Select... / निवडा...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  ...items.map((item) => Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      )),
                ];
              },
              dropdownColor: Colors.white,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
              menuMaxHeight: 300,
            ),
          ),
        ),
        // Show text field when "Other" is selected
        if (isOtherSelected && otherController != null) ...[
          const SizedBox(height: 12),
          TextField(
            controller: otherController,
            decoration: InputDecoration(
              hintText: 'Please specify / कृपया निर्दिष्ट करा',
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
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ],
    );
  }

  Widget _buildDocumentUpload({
    required String label,
    required String? imageUrl,
    required bool uploading,
    required bool required,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: uploading ? null : onTap,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              border: Border.all(color: Colors.pink.shade200),
            ),
            child: uploading
                ? const Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (imageUrl != null && imageUrl.isNotEmpty)
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 120,
                              errorBuilder: (_, __, ___) => _documentPlaceholder(),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (label.contains('Aadhaar')) _aadhaarImageUrl = null;
                                  else if (label.contains('PAN')) _panCardImageUrl = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _documentPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _documentPlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file, size: 32, color: Colors.pink.shade400),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Click to upload document / दस्तऐवज अपलोड करण्यासाठी क्लिक करा',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.pink.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 36, color: Colors.pink.shade400),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Click to upload photo / फोटो अपलोड करण्यासाठी क्लिक करा',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.pink.shade600),
          ),
        ),
      ],
    );
  }
}
