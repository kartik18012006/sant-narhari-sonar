import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/image_picker_service.dart';

/// Holds controllers for one family member (name, relation, age, phone).
class _FamilyMemberEntry {
  final TextEditingController name = TextEditingController();
  final TextEditingController relation = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController phone = TextEditingController();

  void dispose() {
    name.dispose();
    relation.dispose();
    age.dispose();
    phone.dispose();
  }
}

/// Matrimony Registration form — comprehensive form matching screenshots exactly.
/// "Register as Groom" or "Register as Bride".
class MatrimonyRegistrationScreen extends StatefulWidget {
  const MatrimonyRegistrationScreen({super.key, required this.isGroom});

  final bool isGroom;

  @override
  State<MatrimonyRegistrationScreen> createState() => _MatrimonyRegistrationScreenState();
}

class _MatrimonyRegistrationScreenState extends State<MatrimonyRegistrationScreen> {
  // Personal Information Controllers
  final _nameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _ageController = TextEditingController();
  final _birthTimeController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Contact Details Controllers
  final _mobileController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();

  // Education & Occupation
  final _educationController = TextEditingController();
  final _occupationController = TextEditingController();

  // Location
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  // Partner Preferences
  final _expectedEducationController = TextEditingController();
  final _expectedOccupationController = TextEditingController();
  final _expectedHeightController = TextEditingController();
  final _otherExpectationsController = TextEditingController();

  // Lifestyle
  final _hobbiesInterestsController = TextEditingController();
  final _lifeGoalsController = TextEditingController();

  // Dropdown values
  String? _subCaste;
  String? _complexion;
  String? _bloodGroup;
  String? _diet;
  String? _manglik;
  String? _nakshatra;
  String? _rashi;
  String? _gotra;
  String? _maritalStatus;
  String? _disability;
  String? _familyValues;
  String? _financialOutlook;
  String? _communicationStyle;
  String? _expectedFamilyValues;
  String? _expectedFinancialOutlook;
  String? _expectedCommunicationStyle;

  // Custom "Other" values
  final _subCasteOtherController = TextEditingController();
  final _gotraOtherController = TextEditingController();

  // Family Members
  final List<_FamilyMemberEntry> _familyMembers = [];

  // Document images
  String? _aadhaarImageUrl;
  String? _panCardImageUrl;
  String? _passportImageUrl; // Optional
  String? _educationCertificateImageUrl;
  bool _uploadingAadhaar = false;
  bool _uploadingPanCard = false;
  bool _uploadingPassport = false;
  bool _uploadingEducationCertificate = false;

  // Photos
  String? _photoUrl; // Kept for backward compatibility
  String? _closeupPhotoUrl;
  String? _fullPhotoUrl;
  String? _halfPhotoUrl;
  bool _uploadingCloseupPhoto = false;
  bool _uploadingFullPhoto = false;
  bool _uploadingHalfPhoto = false;
  bool _loading = false;

  String get _type => widget.isGroom ? 'groom' : 'bride';
  String get _title => widget.isGroom ? 'Register as Groom / वर म्हणून नोंदणी' : 'Register as Bride / वधू म्हणून नोंदणी';

  @override
  void dispose() {
    _nameController.dispose();
    _dateOfBirthController.dispose();
    _ageController.dispose();
    _birthTimeController.dispose();
    _birthPlaceController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _mobileController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _educationController.dispose();
    _occupationController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _expectedEducationController.dispose();
    _expectedOccupationController.dispose();
    _expectedHeightController.dispose();
    _otherExpectationsController.dispose();
    _hobbiesInterestsController.dispose();
    _lifeGoalsController.dispose();
    _subCasteOtherController.dispose();
    _gotraOtherController.dispose();
    for (final member in _familyMembers) {
      member.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
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
      final age = DateTime.now().year - picked.year;
      if (DateTime.now().month < picked.month || (DateTime.now().month == picked.month && DateTime.now().day < picked.day)) {
        _ageController.text = (age - 1).toString();
      } else {
        _ageController.text = age.toString();
      }
    }
  }

  Future<void> _pickBirthTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      _birthTimeController.text = DateFormat('HH:mm').format(
        DateTime(2000, 1, 1, picked.hour, picked.minute),
      );
    }
  }

  void _addFamilyMember() {
    setState(() => _familyMembers.add(_FamilyMemberEntry()));
  }

  void _removeFamilyMember(int index) {
    _familyMembers[index].dispose();
    setState(() => _familyMembers.removeAt(index));
  }

  Future<String?> _uploadPhoto(String photoType) async {
    return await ImagePickerService.instance.pickAndUploadImage(
      context: context,
      storagePath: 'matrimony/${FirebaseAuthService.instance.currentUser?.uid ?? 'unknown'}/$photoType',
      maxWidth: 1920,
      maxHeight: 1080,
      successMessage: 'Photo uploaded successfully.',
      errorMessage: 'Upload failed. Please try again.',
    );
  }

  Future<String?> _uploadDocument(String documentType) async {
    return await ImagePickerService.instance.pickAndUploadImage(
      context: context,
      storagePath: 'matrimony/${FirebaseAuthService.instance.currentUser?.uid ?? 'unknown'}/documents/$documentType',
      maxWidth: 1920,
      maxHeight: 1080,
      successMessage: 'Document uploaded successfully.',
      errorMessage: 'Upload failed. Please try again.',
    );
  }


  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter full name')),
      );
      return;
    }
    if (_birthPlaceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Birth Place is required')),
      );
      return;
    }
    if (_aadhaarImageUrl == null || _aadhaarImageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload Aadhaar Card')),
      );
      return;
    }
    if (_educationCertificateImageUrl == null || _educationCertificateImageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload Education Certificate')),
      );
      return;
    }
    if (_complexion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complexion is required')),
      );
      return;
    }
    if (_bloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blood Group is required')),
      );
      return;
    }
    if (_diet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diet is required')),
      );
      return;
    }
    if (_manglik == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manglik status is required')),
      );
      return;
    }
    if (_nakshatra == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nakshatra is required')),
      );
      return;
    }
    if (_rashi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rashi is required')),
      );
      return;
    }
    if (_maritalStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marital Status is required')),
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
        phone: _mobileController.text.trim().isEmpty ? null : _mobileController.text.trim(),
        whatsappNumber: _whatsappController.text.trim().isEmpty ? null : _whatsappController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        dateOfBirth: _dateOfBirthController.text.trim().isEmpty ? null : _dateOfBirthController.text.trim(),
        age: _ageController.text.trim().isEmpty ? null : _ageController.text.trim(),
        birthTime: _birthTimeController.text.trim().isEmpty ? null : _birthTimeController.text.trim(),
        birthPlace: _birthPlaceController.text.trim().isEmpty ? null : _birthPlaceController.text.trim(),
        height: _heightController.text.trim().isEmpty ? null : _heightController.text.trim(),
        weight: _weightController.text.trim().isEmpty ? null : _weightController.text.trim(),
        complexion: _complexion,
        bloodGroup: _bloodGroup,
        diet: _diet,
        manglik: _manglik,
        nakshatra: _nakshatra,
        rashi: _rashi,
        gotra: (_gotra != null && (_gotra!.contains('Other') || _gotra!.contains('इतर'))) && _gotraOtherController.text.trim().isNotEmpty
            ? _gotraOtherController.text.trim()
            : _gotra,
        maritalStatus: _maritalStatus,
        disability: _disability,
        familyValues: _familyValues,
        financialOutlook: _financialOutlook,
        communicationStyle: _communicationStyle,
        hobbiesInterests: _hobbiesInterestsController.text.trim().isEmpty ? null : _hobbiesInterestsController.text.trim(),
        lifeGoals: _lifeGoalsController.text.trim().isEmpty ? null : _lifeGoalsController.text.trim(),
        education: _educationController.text.trim().isEmpty ? null : _educationController.text.trim(),
        occupation: _occupationController.text.trim().isEmpty ? null : _occupationController.text.trim(),
        subcaste: (_subCaste != null && (_subCaste!.contains('Other') || _subCaste!.contains('इतर'))) && _subCasteOtherController.text.trim().isNotEmpty
            ? _subCasteOtherController.text.trim()
            : _subCaste,
        district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
        state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
        country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
        expectedEducation: _expectedEducationController.text.trim().isEmpty ? null : _expectedEducationController.text.trim(),
        expectedOccupation: _expectedOccupationController.text.trim().isEmpty ? null : _expectedOccupationController.text.trim(),
        expectedHeight: _expectedHeightController.text.trim().isEmpty ? null : _expectedHeightController.text.trim(),
        expectedFamilyValues: _expectedFamilyValues,
        expectedFinancialOutlook: _expectedFinancialOutlook,
        expectedCommunicationStyle: _expectedCommunicationStyle,
        otherExpectations: _otherExpectationsController.text.trim().isEmpty ? null : _otherExpectationsController.text.trim(),
        familyMembers: _familyMembers
            .map((e) => {
                  'name': e.name.text.trim(),
                  'relation': e.relation.text.trim(),
                  'age': e.age.text.trim(),
                  'number': e.phone.text.trim(),
                })
            .where((m) => m['name']!.isNotEmpty)
            .toList(),
        createdBy: profile?['displayName'] as String? ?? user.displayName,
        photoUrl: _photoUrl,
        closeupPhotoUrl: _closeupPhotoUrl,
        fullPhotoUrl: _fullPhotoUrl,
        halfPhotoUrl: _halfPhotoUrl,
        documents: {
          'aadhaar': _aadhaarImageUrl,
          'panCard': _panCardImageUrl,
          'passport': _passportImageUrl,
          'educationCertificate': _educationCertificateImageUrl,
        },
      );
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Matrimonial profile submitted successfully. Admin may review before publishing.'),
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
            // Photos Section
            _buildSectionHeader('Photos / फोटो', color: Colors.pink.shade100),
            const SizedBox(height: 16),
            _buildCircularPhotoUpload(
              label: 'Close-up Photo / क्लोज-अप फोटो',
              photoUrl: _closeupPhotoUrl,
              uploading: _uploadingCloseupPhoto,
              onTap: () async {
                setState(() => _uploadingCloseupPhoto = true);
                final url = await _uploadPhoto('closeup_photo');
                if (!mounted) return;
                setState(() {
                  _uploadingCloseupPhoto = false;
                  if (url != null) _closeupPhotoUrl = url;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildRectangularPhotoUpload(
              label: 'Full Photo / पूर्ण फोटो',
              photoUrl: _fullPhotoUrl,
              uploading: _uploadingFullPhoto,
              onTap: () async {
                setState(() => _uploadingFullPhoto = true);
                final url = await _uploadPhoto('full_photo');
                if (!mounted) return;
                setState(() {
                  _uploadingFullPhoto = false;
                  if (url != null) _fullPhotoUrl = url;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildRectangularPhotoUpload(
              label: 'Half Photo / अर्धा फोटो',
              photoUrl: _halfPhotoUrl,
              uploading: _uploadingHalfPhoto,
              onTap: () async {
                setState(() => _uploadingHalfPhoto = true);
                final url = await _uploadPhoto('half_photo');
                if (!mounted) return;
                setState(() {
                  _uploadingHalfPhoto = false;
                  if (url != null) _halfPhotoUrl = url;
                });
              },
            ),
            const SizedBox(height: 32),

            // Section 1: Personal Information
            _buildSectionHeader('1. Personal Information / वैयक्तिक माहिती'),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Full Name / मुलाचे पूर्ण नाव',
              controller: _nameController,
              icon: Icons.person,
              required: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'Sub Caste / पोटजात',
                    value: _subCaste,
                    items: AppTheme.subcasteOptions,
                    icon: Icons.category,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Date of Birth / जन्म तारीख',
              controller: _dateOfBirthController,
              icon: Icons.calendar_today,
              readOnly: true,
              onTap: _pickDateOfBirth,
              hint: 'dd/mm/yyyy',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Age / वय',
              controller: _ageController,
              icon: Icons.access_time,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Birth Time / जन्म वेळ',
              controller: _birthTimeController,
              icon: Icons.access_time,
              readOnly: true,
              onTap: _pickBirthTime,
              hint: '--:--',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Birth Place / जन्म स्थळ',
              controller: _birthPlaceController,
              icon: Icons.location_on,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Height (e.g. 5 ft 8 in) / उंची',
              controller: _heightController,
              icon: Icons.height,
              hint: 'e.g. 5 ft 8 in',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Weight (kg) / वजन (kg)',
              controller: _weightController,
              icon: Icons.monitor_weight,
              hint: 'e.g. 55',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Complexion / रंग / वर्ण',
              value: _complexion,
              items: AppTheme.complexionOptions,
              icon: Icons.palette,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Blood Group / रक्तगट',
              value: _bloodGroup,
              items: AppTheme.bloodGroupOptions,
              icon: Icons.water_drop,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Diet / आहार',
              value: _diet,
              items: AppTheme.dietOptions,
              icon: Icons.restaurant,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Are you Manglik? / मांगलिक आहे का?',
              value: _manglik,
              items: AppTheme.manglikOptions,
              icon: Icons.help_outline,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Nakshatra / नक्षत्र',
              value: _nakshatra,
              items: AppTheme.nakshatraOptions,
              icon: Icons.star,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Rashi / राशी',
              value: _rashi,
              items: AppTheme.rashiOptions,
              icon: Icons.auto_awesome,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Gotra / गोत्र',
              value: _gotra,
              items: AppTheme.gotraOptions,
              icon: Icons.account_tree,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Marital Status / वैवाहिक स्थिती',
              value: _maritalStatus,
              items: widget.isGroom ? AppTheme.maritalStatusOptionsGroom : AppTheme.maritalStatusOptionsBride,
              icon: Icons.favorite,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Disability / अपंगत्व',
              value: _disability,
              items: AppTheme.disabilityOptions,
              icon: Icons.accessible,
            ),
            const SizedBox(height: 32),

            // Section 2: Personality & Lifestyle
            _buildSectionHeader('Personality & Lifestyle / व्यक्तिमत्व आणि जीवनशैली', color: Colors.pink.shade100),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Family Values / कौटुंबिक मूल्ये',
              value: _familyValues,
              items: AppTheme.familyValuesOptions,
              icon: Icons.family_restroom,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Financial Outlook / आर्थिक दृष्टिकोन',
              value: _financialOutlook,
              items: AppTheme.financialOutlookOptions,
              icon: Icons.account_balance_wallet,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Communication Style / संवाद शैली',
              value: _communicationStyle,
              items: AppTheme.communicationStyleOptions,
              icon: Icons.chat_bubble_outline,
            ),
            const SizedBox(height: 16),
            _buildTextArea(
              label: 'Hobbies & Interests / छंद आणि आवड',
              controller: _hobbiesInterestsController,
              icon: Icons.sports_esports,
            ),
            const SizedBox(height: 16),
            _buildTextArea(
              label: 'Life Goals / जीवनातील ध्येये',
              controller: _lifeGoalsController,
              icon: Icons.flag,
            ),
            const SizedBox(height: 32),

            // Section 3: Contact Details
            _buildSectionHeader('2. Contact Details / संपर्क तपशील', color: Colors.red.shade100),
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

            // Section 4: Education & Occupation
            _buildSectionHeader('3. Education & Occupation / शिक्षण आणि व्यवसाय'),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Education / शिक्षण',
              controller: _educationController,
              icon: Icons.school,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Occupation / व्यवसाय',
              controller: _occupationController,
              icon: Icons.work,
            ),
            const SizedBox(height: 32),

            // Section 5: Location
            _buildSectionHeader('4. Location / स्थान'),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'District / जिल्हा',
              controller: _districtController,
              icon: Icons.location_city,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'State / राज्य',
              controller: _stateController,
              icon: Icons.map,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Country / देश',
              controller: _countryController,
              icon: Icons.public,
            ),
            const SizedBox(height: 32),

            // Section 6: Partner Preferences
            _buildSectionHeader('7. Partner Preferences / जोडीदाराविषयी अपेक्षा ❤️', color: Colors.red.shade100),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Expected Education / अपेक्षित शिक्षण',
              controller: _expectedEducationController,
              icon: Icons.school,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Expected Occupation / अपेक्षित व्यवसाय',
              controller: _expectedOccupationController,
              icon: Icons.work,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Expected Height / अपेक्षित उंची',
              controller: _expectedHeightController,
              icon: Icons.height,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Family Values / कौटुंबिक मूल्ये',
              value: _expectedFamilyValues,
              items: AppTheme.familyValuesOptions,
              icon: Icons.family_restroom,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Financial Outlook / आर्थिक दृष्टिकोन',
              value: _expectedFinancialOutlook,
              items: AppTheme.financialOutlookOptions,
              icon: Icons.account_balance_wallet,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Communication Style / संवाद शैली',
              value: _expectedCommunicationStyle,
              items: AppTheme.communicationStyleOptions,
              icon: Icons.chat_bubble_outline,
            ),
            const SizedBox(height: 16),
            _buildTextArea(
              label: 'Other Expectations / इतर अपेक्षा',
              controller: _otherExpectationsController,
              icon: Icons.note,
            ),
            const SizedBox(height: 32),

            // Section 7: Family Members
            _buildSectionHeader('8. Family Members / कुटुंब सदस्य', color: Colors.pink.shade100),
            const SizedBox(height: 16),
            SizedBox(
              height: AppTheme.buttonHeight,
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
                            'Family Member ${i + 1} / कुटुंब सदस्य ${i + 1}',
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
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Relation / नाते',
                        controller: e.relation,
                        icon: Icons.people,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Age / वय',
                        controller: e.age,
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Phone Number / फोन नंबर',
                        controller: e.phone,
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

            // Section 8: KYC & Document Verification
            _buildSectionHeader('9. KYC & Document Verification / केवायसी आणि कागदपत्र पडताळणी', color: Colors.red.shade100),
            const SizedBox(height: 16),
            Text(
              'Please select the documents you have and upload them for verification. / कृपया तुमच्याकडे असलेली कागदपत्रे निवडा आणि पडताळणीसाठी अपलोड करा.',
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
            const SizedBox(height: 16),
            _buildDocumentUpload(
              label: 'Passport (Optional) / पासपोर्ट (ऐच्छिक)',
              imageUrl: _passportImageUrl,
              uploading: _uploadingPassport,
              required: false,
              onTap: () async {
                setState(() => _uploadingPassport = true);
                final url = await _uploadDocument('passport');
                if (!mounted) return;
                setState(() {
                  _uploadingPassport = false;
                  if (url != null) _passportImageUrl = url;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDocumentUpload(
              label: 'Highest Education Certificate / सर्वोच्च शिक्षण प्रमाणपत्र',
              imageUrl: _educationCertificateImageUrl,
              uploading: _uploadingEducationCertificate,
              required: true,
              onTap: () async {
                setState(() => _uploadingEducationCertificate = true);
                final url = await _uploadDocument('education_certificate');
                if (!mounted) return;
                setState(() {
                  _uploadingEducationCertificate = false;
                  if (url != null) _educationCertificateImageUrl = url;
                });
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color ?? Colors.pink.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color != null ? Colors.red.shade700 : Colors.pink.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool required = false,
    bool readOnly = false,
    VoidCallback? onTap,
    String? hint,
    TextInputType? keyboardType,
    String? prefix,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: keyboardType == TextInputType.phone
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

  Widget _buildTextArea({
    required String label,
    required TextEditingController controller,
    IconData? icon,
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
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
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
    bool required = false,
  }) {
    final isOtherSelected = value != null && (value.contains('Other') || value.contains('इतर'));
    TextEditingController? otherController;
    if (label.contains('Sub Caste')) {
      otherController = _subCasteOtherController;
    } else if (label.contains('Gotra')) {
      otherController = _gotraOtherController;
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
            ],
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
                  // Handle null selection (clearing the field)
                  if (v == null) {
                    if (label.contains('Sub Caste')) {
                      _subCaste = null;
                      _subCasteOtherController.clear();
                    } else if (label.contains('Complexion')) _complexion = null;
                    else if (label.contains('Blood Group')) _bloodGroup = null;
                    else if (label.contains('Diet')) _diet = null;
                    else if (label.contains('Manglik')) _manglik = null;
                    else if (label.contains('Nakshatra')) _nakshatra = null;
                    else if (label.contains('Rashi')) _rashi = null;
                    else if (label.contains('Gotra')) {
                      _gotra = null;
                      _gotraOtherController.clear();
                    } else if (label.contains('Marital Status')) _maritalStatus = null;
                    else if (label.contains('Disability')) _disability = null;
                    else if (label.contains('Family Values') && !label.contains('Expected')) _familyValues = null;
                    else if (label.contains('Financial Outlook') && !label.contains('Expected')) _financialOutlook = null;
                    else if (label.contains('Communication Style') && !label.contains('Expected')) _communicationStyle = null;
                    else if (label.contains('Expected') && label.contains('Family Values')) _expectedFamilyValues = null;
                    else if (label.contains('Expected') && label.contains('Financial Outlook')) _expectedFinancialOutlook = null;
                    else if (label.contains('Expected') && label.contains('Communication Style')) _expectedCommunicationStyle = null;
                  } else {
                    // Handle actual value selection
                    if (label.contains('Sub Caste')) {
                      _subCaste = v;
                      if (!isOtherSelected) _subCasteOtherController.clear();
                    } else if (label.contains('Complexion')) _complexion = v;
                    else if (label.contains('Blood Group')) _bloodGroup = v;
                    else if (label.contains('Diet')) _diet = v;
                    else if (label.contains('Manglik')) _manglik = v;
                    else if (label.contains('Nakshatra')) _nakshatra = v;
                    else if (label.contains('Rashi')) _rashi = v;
                    else if (label.contains('Gotra')) {
                      _gotra = v;
                      if (!isOtherSelected) _gotraOtherController.clear();
                    } else if (label.contains('Marital Status')) _maritalStatus = v;
                    else if (label.contains('Disability')) _disability = v;
                    else if (label.contains('Family Values') && !label.contains('Expected')) _familyValues = v;
                    else if (label.contains('Financial Outlook') && !label.contains('Expected')) _financialOutlook = v;
                    else if (label.contains('Communication Style') && !label.contains('Expected')) _communicationStyle = v;
                    else if (label.contains('Expected') && label.contains('Family Values')) _expectedFamilyValues = v;
                    else if (label.contains('Expected') && label.contains('Financial Outlook')) _expectedFinancialOutlook = v;
                    else if (label.contains('Expected') && label.contains('Communication Style')) _expectedCommunicationStyle = v;
                  }
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


  Widget _buildCircularPhotoUpload({
    required String label,
    required String? photoUrl,
    required bool uploading,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: uploading ? null : onTap,
          child: Container(
            height: 150,
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
                : (photoUrl != null && photoUrl.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        child: Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 150,
                          errorBuilder: (_, __, ___) => _rectangularPhotoPlaceholder(),
                        ),
                      )
                    : _rectangularPhotoPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildRectangularPhotoUpload({
    required String label,
    required String? photoUrl,
    required bool uploading,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: uploading ? null : onTap,
          child: Container(
            height: 150,
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
                : (photoUrl != null && photoUrl.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                        child: Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 150,
                          errorBuilder: (_, __, ___) => _rectangularPhotoPlaceholder(),
                        ),
                      )
                    : _rectangularPhotoPlaceholder(),
          ),
        ),
      ],
    );
  }


  Widget _rectangularPhotoPlaceholder() {
    return Container(
      width: double.infinity,
      height: 150,
      alignment: Alignment.center,
      child: Column(
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
                                  else if (label.contains('Passport')) _passportImageUrl = null;
                                  else if (label.contains('Education')) _educationCertificateImageUrl = null;
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

}
