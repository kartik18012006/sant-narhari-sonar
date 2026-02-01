import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/firestore_service.dart';

/// Business Advertisement Form — comprehensive form matching screenshots exactly.
class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({super.key});

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  // Business Information
  String? _ownerPhotoUrl;
  String? _businessLogoUrl;
  bool _uploadingOwnerPhoto = false;
  bool _uploadingBusinessLogo = false;

  // Business Photos
  String? _outdoorPhotoUrl;
  String? _interiorPhoto1Url;
  String? _interiorPhoto2Url;
  String? _interiorPhoto3Url;
  bool _uploadingOutdoorPhoto = false;
  bool _uploadingInteriorPhoto1 = false;
  bool _uploadingInteriorPhoto2 = false;
  bool _uploadingInteriorPhoto3 = false;

  // Business Details
  final _businessNameController = TextEditingController();
  final _typeOfBusinessController = TextEditingController();
  final _dateOfEstablishmentController = TextEditingController();
  String? _businessStructure;

  // Working Hours
  final Map<String, Map<String, dynamic>> _workingHours = {
    'monday': {'enabled': true, 'from': '10:00 AM', 'to': '08:00 PM'},
    'tuesday': {'enabled': true, 'from': '10:00 AM', 'to': '08:00 PM'},
    'wednesday': {'enabled': true, 'from': '10:00 AM', 'to': '08:00 PM'},
    'thursday': {'enabled': true, 'from': '10:00 AM', 'to': '08:00 PM'},
    'friday': {'enabled': true, 'from': '10:00 AM', 'to': '08:00 PM'},
    'saturday': {'enabled': true, 'from': '10:00 AM', 'to': '06:00 PM'},
    'sunday': {'enabled': false, 'from': '', 'to': ''},
  };

  // Business Description
  final _businessDescriptionController = TextEditingController();

  // Business Address
  final _businessAddressController = TextEditingController();
  final _businessPincodeController = TextEditingController();
  final _businessCityVillageController = TextEditingController();
  final _businessTalukaController = TextEditingController();
  final _businessDistrictController = TextEditingController();
  final _businessStateController = TextEditingController();

  // Contact Information
  final _businessEmailController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _websiteController = TextEditingController();

  // Owner Details
  final _ownerNameController = TextEditingController();
  final _ownerDateOfBirthController = TextEditingController();
  final _ownerMobileController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerResidentialAddressController = TextEditingController();
  String? _ownerSubcaste;
  String? _ownerGender;

  // Custom "Other" values
  final _ownerSubcasteOtherController = TextEditingController();
  final _ownerGenderOtherController = TextEditingController();

  // KYC Documents - Owner's documents (image uploads)
  String? _ownersAadhaarImageUrl;
  String? _ownersPanCardImageUrl; // Optional
  bool _uploadingOwnersAadhaar = false;
  bool _uploadingOwnersPanCard = false;
  
  // Other business documents (keep as checkboxes for now)
  bool _hasBusinessPan = false;
  bool _hasGstCertificate = false;
  bool _hasUdyamCertificate = false;
  bool _hasShopActLicense = false;
  bool _hasIec = false;
  bool _hasBusinessAddressProof = false;
  bool _hasSignature = false;

  bool _loading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _typeOfBusinessController.dispose();
    _dateOfEstablishmentController.dispose();
    _businessDescriptionController.dispose();
    _businessAddressController.dispose();
    _businessPincodeController.dispose();
    _businessCityVillageController.dispose();
    _businessTalukaController.dispose();
    _businessDistrictController.dispose();
    _businessStateController.dispose();
    _businessEmailController.dispose();
    _businessPhoneController.dispose();
    _websiteController.dispose();
    _ownerNameController.dispose();
    _ownerDateOfBirthController.dispose();
    _ownerMobileController.dispose();
    _ownerEmailController.dispose();
    _ownerResidentialAddressController.dispose();
    _ownerSubcasteOtherController.dispose();
    _ownerGenderOtherController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfEstablishment() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(1900),
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
      _dateOfEstablishmentController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> _pickOwnerDateOfBirth() async {
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
      _ownerDateOfBirthController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> _pickTime(BuildContext context, String day, String type) async {
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
      setState(() {
        final hour = picked.hour;
        final minute = picked.minute;
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        _workingHours[day]![type] = '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      });
    }
  }

  Future<String?> _uploadDocument(String documentType) async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) return null;
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
    if (source == null || !mounted) return null;
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: source, maxWidth: 1920, maxHeight: 1080, imageQuality: 85);
      if (xFile == null || !mounted) return null;
      final bytes = await xFile.readAsBytes();
      if (bytes.length > FirebaseStorageService.maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image must be under 1MB. Please choose a smaller image.')),
          );
        }
        return null;
      }
      final path = FirebaseStorageService.instance.uniquePath('advertisements/${user.uid}/documents/$documentType', extension: 'jpg');
      final url = await FirebaseStorageService.instance.uploadImage(bytes: bytes, path: path);
      if (!mounted) return null;
      if (url != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully.'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed. Please try again.')));
      }
      return url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      return null;
    }
  }

  Future<String?> _uploadPhoto(String fieldName) async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) return null;
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
    if (source == null || !mounted) return null;
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (xFile == null || !mounted) return null;
      final bytes = await xFile.readAsBytes();
      if (bytes.length > FirebaseStorageService.maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image must be under 1MB. Please choose a smaller image.')),
          );
        }
        return null;
      }
      final path = FirebaseStorageService.instance.uniquePath('advertisements/${user.uid}/$fieldName', extension: 'jpg');
      return await FirebaseStorageService.instance.uploadImage(bytes: bytes, path: path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      return null;
    }
  }

  Future<void> _onSubmit() async {
    final businessName = _businessNameController.text.trim();
    if (businessName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter business name')),
      );
      return;
    }
    if (_ownersAadhaarImageUrl == null || _ownersAadhaarImageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload Owner\'s Aadhaar Card')),
      );
      return;
    }
    final ownerName = _ownerNameController.text.trim();
    if (ownerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter owner full name')),
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
      await FirestoreService.instance.addAdvertisement(
        userId: user.uid,
        businessName: businessName,
        typeOfBusiness: _typeOfBusinessController.text.trim().isEmpty ? null : _typeOfBusinessController.text.trim(),
        businessStructure: _businessStructure,
        dateOfEstablishment: _dateOfEstablishmentController.text.trim().isEmpty ? null : _dateOfEstablishmentController.text.trim(),
        businessDescription: _businessDescriptionController.text.trim().isEmpty ? null : _businessDescriptionController.text.trim(),
        businessAddress: _businessAddressController.text.trim().isEmpty ? null : _businessAddressController.text.trim(),
        businessPincode: _businessPincodeController.text.trim().isEmpty ? null : _businessPincodeController.text.trim(),
        businessCityVillage: _businessCityVillageController.text.trim().isEmpty ? null : _businessCityVillageController.text.trim(),
        businessTaluka: _businessTalukaController.text.trim().isEmpty ? null : _businessTalukaController.text.trim(),
        businessDistrict: _businessDistrictController.text.trim().isEmpty ? null : _businessDistrictController.text.trim(),
        businessState: _businessStateController.text.trim().isEmpty ? null : _businessStateController.text.trim(),
        businessEmail: _businessEmailController.text.trim().isEmpty ? null : _businessEmailController.text.trim(),
        businessPhone: _businessPhoneController.text.trim().isEmpty ? null : _businessPhoneController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        ownerName: ownerName,
        ownerSubcaste: (_ownerSubcaste != null && (_ownerSubcaste!.contains('Other') || _ownerSubcaste!.contains('इतर'))) && _ownerSubcasteOtherController.text.trim().isNotEmpty
            ? _ownerSubcasteOtherController.text.trim()
            : _ownerSubcaste,
        ownerDateOfBirth: _ownerDateOfBirthController.text.trim().isEmpty ? null : _ownerDateOfBirthController.text.trim(),
        ownerGender: (_ownerGender != null && (_ownerGender!.contains('Other') || _ownerGender!.contains('इतर'))) && _ownerGenderOtherController.text.trim().isNotEmpty
            ? _ownerGenderOtherController.text.trim()
            : _ownerGender,
        ownerMobile: _ownerMobileController.text.trim().isEmpty ? null : _ownerMobileController.text.trim(),
        ownerEmail: _ownerEmailController.text.trim().isEmpty ? null : _ownerEmailController.text.trim(),
        ownerResidentialAddress: _ownerResidentialAddressController.text.trim().isEmpty ? null : _ownerResidentialAddressController.text.trim(),
        photos: {
          if (_ownerPhotoUrl != null) 'ownerPhoto': _ownerPhotoUrl!,
          if (_businessLogoUrl != null) 'businessLogo': _businessLogoUrl!,
          if (_outdoorPhotoUrl != null) 'outdoorPhoto': _outdoorPhotoUrl!,
          if (_interiorPhoto1Url != null) 'interiorPhoto1': _interiorPhoto1Url!,
          if (_interiorPhoto2Url != null) 'interiorPhoto2': _interiorPhoto2Url!,
          if (_interiorPhoto3Url != null) 'interiorPhoto3': _interiorPhoto3Url!,
        },
        workingHours: _workingHours,
        documents: {
          'ownersAadhaar': _ownersAadhaarImageUrl,
          'ownersPanCard': _ownersPanCardImageUrl,
          'businessPan': _hasBusinessPan ? 'true' : null,
          'gstCertificate': _hasGstCertificate ? 'true' : null,
          'udyamCertificate': _hasUdyamCertificate ? 'true' : null,
          'shopActLicense': _hasShopActLicense ? 'true' : null,
          'iec': _hasIec ? 'true' : null,
          'businessAddressProof': _hasBusinessAddressProof ? 'true' : null,
          'signature': _hasSignature ? 'true' : null,
        },
        createdBy: createdBy,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business advertisement submitted successfully. Admin may review before publishing.'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
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
          'Business Advertisement Form / व्यवसाय जाहिरात अर्ज',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Business Information
            _buildSectionHeader('1 Business Information / व्यवसाय माहिती', color: Colors.pink.shade100),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCircularPhotoUpload(
                    label: 'Owner Photo / मालकाचा फोटो',
                    photoUrl: _ownerPhotoUrl,
                    uploading: _uploadingOwnerPhoto,
                    onTap: () async {
                      setState(() => _uploadingOwnerPhoto = true);
                      final url = await _uploadPhoto('owner_photo');
                      setState(() {
                        _uploadingOwnerPhoto = false;
                        if (url != null) _ownerPhotoUrl = url;
                      });
                    },
                    icon: Icons.person,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCircularPhotoUpload(
                    label: 'Business Logo / व्यवसाय लोगो',
                    photoUrl: _businessLogoUrl,
                    uploading: _uploadingBusinessLogo,
                    onTap: () async {
                      setState(() => _uploadingBusinessLogo = true);
                      final url = await _uploadPhoto('business_logo');
                      setState(() {
                        _uploadingBusinessLogo = false;
                        if (url != null) _businessLogoUrl = url;
                      });
                    },
                    icon: Icons.business,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section 2: Business Photos
            _buildSectionHeader('Business Photos / व्यवसाय फोटो', color: Colors.pink.shade100, icon: Icons.photo),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRectangularPhotoUpload(
                    label: 'Outdoor Photo / बाहेरील फोटो',
                    photoUrl: _outdoorPhotoUrl,
                    uploading: _uploadingOutdoorPhoto,
                    onTap: () async {
                      setState(() => _uploadingOutdoorPhoto = true);
                      final url = await _uploadPhoto('outdoor_photo');
                      setState(() {
                        _uploadingOutdoorPhoto = false;
                        if (url != null) _outdoorPhotoUrl = url;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRectangularPhotoUpload(
                    label: 'Interior Photo 1 / आतील फोटो 1',
                    photoUrl: _interiorPhoto1Url,
                    uploading: _uploadingInteriorPhoto1,
                    onTap: () async {
                      setState(() => _uploadingInteriorPhoto1 = true);
                      final url = await _uploadPhoto('interior_photo_1');
                      setState(() {
                        _uploadingInteriorPhoto1 = false;
                        if (url != null) _interiorPhoto1Url = url;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRectangularPhotoUpload(
                    label: 'Interior Photo 2 / आतील फोटो 2',
                    photoUrl: _interiorPhoto2Url,
                    uploading: _uploadingInteriorPhoto2,
                    onTap: () async {
                      setState(() => _uploadingInteriorPhoto2 = true);
                      final url = await _uploadPhoto('interior_photo_2');
                      setState(() {
                        _uploadingInteriorPhoto2 = false;
                        if (url != null) _interiorPhoto2Url = url;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRectangularPhotoUpload(
                    label: 'Interior Photo 3 / आतील फोटो 3',
                    photoUrl: _interiorPhoto3Url,
                    uploading: _uploadingInteriorPhoto3,
                    onTap: () async {
                      setState(() => _uploadingInteriorPhoto3 = true);
                      final url = await _uploadPhoto('interior_photo_3');
                      setState(() {
                        _uploadingInteriorPhoto3 = false;
                        if (url != null) _interiorPhoto3Url = url;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section 3: Business Details
            _buildSectionHeader('Business Details / व्यवसाय तपशील', color: Colors.pink.shade100),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Business Name / व्यवसायाचे नाव',
              controller: _businessNameController,
              icon: Icons.business,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Type of Business / Nature of Work / व्यवसायाचा प्रकार / कामाचे स्वरूप',
              controller: _typeOfBusinessController,
              icon: Icons.work,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Business Structure / व्यवसाय रचना',
              value: _businessStructure,
              items: AppTheme.businessStructureOptions,
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Date of Establishment / स्थापनेची तारीख',
              controller: _dateOfEstablishmentController,
              icon: Icons.calendar_today,
              readOnly: true,
              onTap: _pickDateOfEstablishment,
              hint: 'dd/mm/yyyy',
            ),
            const SizedBox(height: 32),

            // Section 4: Working Hours
            _buildSectionHeader('Working Hours / कामाचे तास', color: Colors.pink.shade100, icon: Icons.access_time),
            const SizedBox(height: 16),
            _buildWorkingHoursDay('monday', 'Monday / सोमवार'),
            const SizedBox(height: 12),
            _buildWorkingHoursDay('tuesday', 'Tuesday / मंगळवार'),
            const SizedBox(height: 12),
            _buildWorkingHoursDay('wednesday', 'Wednesday / बुधवार'),
            const SizedBox(height: 12),
            _buildWorkingHoursDay('thursday', 'Thursday / गुरुवार'),
            const SizedBox(height: 12),
            _buildWorkingHoursDay('friday', 'Friday / शुक्रवार'),
            const SizedBox(height: 12),
            _buildWorkingHoursDay('saturday', 'Saturday / शनिवार'),
            const SizedBox(height: 12),
            _buildWorkingHoursDay('sunday', 'Sunday / रविवार'),
            const SizedBox(height: 32),

            // Section 5: Business Description
            _buildSectionHeader('Business Description / व्यवसाय वर्णन', color: Colors.pink.shade100),
            const SizedBox(height: 16),
            _buildTextArea(
              label: 'Business Description / व्यवसाय वर्णन',
              controller: _businessDescriptionController,
              icon: Icons.description,
              required: true,
            ),
            const SizedBox(height: 32),

            // Section 6: Business Address
            _buildSectionHeader('Business Address / व्यवसाय पत्ता', color: Colors.pink.shade100, icon: Icons.location_on),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Business Address (e.g. Lane, Landmark) / व्यवसाय पत्ता (उदा. गल्ली, लँड मार्क)',
              controller: _businessAddressController,
              icon: Icons.location_on,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'PIN Code / पिन कोड',
              controller: _businessPincodeController,
              icon: Icons.pin,
              keyboardType: TextInputType.number,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'City/Village / शहर/गाव',
              controller: _businessCityVillageController,
              icon: Icons.location_city,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Taluka / तालुका',
              controller: _businessTalukaController,
              icon: Icons.map,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'District / जिल्हा',
              controller: _businessDistrictController,
              icon: Icons.location_city,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'State / राज्य',
              controller: _businessStateController,
              icon: Icons.map,
              required: true,
            ),
            const SizedBox(height: 32),

            // Section 7: Contact Information
            _buildSectionHeader('Contact Information / संपर्क माहिती', color: Colors.pink.shade100, icon: Icons.phone),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Business Email ID / व्यवसाय ईमेल आयडी',
              controller: _businessEmailController,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Business Phone / Mobile Number / व्यवसाय फोन / मोबाईल नंबर',
              controller: _businessPhoneController,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              prefix: '+91 ',
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Website (if available) / वेबसाइट (असल्यास)',
              controller: _websiteController,
              icon: Icons.language,
            ),
            const SizedBox(height: 32),

            // Section 8: Owner Details
            _buildSectionHeader('2 Owner Details / मालक तपशील', color: Colors.pink.shade100, icon: Icons.person),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Full Name / पूर्ण नाव',
              controller: _ownerNameController,
              icon: Icons.person,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Owner Sub-caste / मालकाची पोटजात',
              value: _ownerSubcaste,
              items: AppTheme.subcasteOptions,
              icon: Icons.category,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Date of Birth / जन्मतारीख',
              controller: _ownerDateOfBirthController,
              icon: Icons.calendar_today,
              readOnly: true,
              onTap: _pickOwnerDateOfBirth,
              hint: 'dd/mm/yyyy',
              required: true,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Gender / लिंग',
              value: _ownerGender,
              items: AppTheme.genderOptions,
              icon: Icons.person_outline,
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Mobile Number / मोबाईल नंबर',
              controller: _ownerMobileController,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              prefix: '+91 ',
              required: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Email ID / ईमेल आयडी',
              controller: _ownerEmailController,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextArea(
              label: 'Residential Address / राहण्याचा पत्ता',
              controller: _ownerResidentialAddressController,
              icon: Icons.home,
            ),
            const SizedBox(height: 32),

            // Section 9: KYC & Business Documents
            _buildSectionHeader('3 KYC & Business Documents / केवायसी आणि व्यवसाय दस्तऐवज', color: Colors.pink.shade100),
            const SizedBox(height: 16),
            Text(
              'Please select the documents you have and upload them for verification. / कृपया तुमच्याकडे असलेली कागदपत्रे निवडा आणि पडताळणीसाठी अपलोड करा.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            _buildDocumentUpload(
              label: 'Owner\'s Aadhaar Card / मालकाचे आधार कार्ड',
              imageUrl: _ownersAadhaarImageUrl,
              uploading: _uploadingOwnersAadhaar,
              required: true,
              onTap: () async {
                setState(() => _uploadingOwnersAadhaar = true);
                final url = await _uploadDocument('owners_aadhaar');
                if (!mounted) return;
                setState(() {
                  _uploadingOwnersAadhaar = false;
                  if (url != null) _ownersAadhaarImageUrl = url;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDocumentUpload(
              label: 'Owner\'s PAN Card / मालकाचे पॅन कार्ड (Optional)',
              imageUrl: _ownersPanCardImageUrl,
              uploading: _uploadingOwnersPanCard,
              required: false,
              onTap: () async {
                setState(() => _uploadingOwnersPanCard = true);
                final url = await _uploadDocument('owners_pan_card');
                if (!mounted) return;
                setState(() {
                  _uploadingOwnersPanCard = false;
                  if (url != null) _ownersPanCardImageUrl = url;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCheckbox(
                    label: 'Business PAN / व्यवसाय पॅन',
                    value: _hasBusinessPan,
                    onChanged: (v) => setState(() => _hasBusinessPan = v ?? false),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCheckbox(
                    label: 'GST Certificate / जीएसटी प्रमाणपत्र',
                    value: _hasGstCertificate,
                    onChanged: (v) => setState(() => _hasGstCertificate = v ?? false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCheckbox(
                    label: 'Udyam / MSME Certificate / उद्यम / एमएसएमई प्रमाणपत्र',
                    value: _hasUdyamCertificate,
                    onChanged: (v) => setState(() => _hasUdyamCertificate = v ?? false),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCheckbox(
                    label: 'Shop Act License / दुकान कायदा परवाना',
                    value: _hasShopActLicense,
                    onChanged: (v) => setState(() => _hasShopActLicense = v ?? false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCheckbox(
                    label: 'Import Export Code (IEC) / आयात निर्यात कोड',
                    value: _hasIec,
                    onChanged: (v) => setState(() => _hasIec = v ?? false),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCheckbox(
                    label: 'Business Address Proof / व्यवसाय पत्त्याचा पुरावा',
                    value: _hasBusinessAddressProof,
                    onChanged: (v) => setState(() => _hasBusinessAddressProof = v ?? false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCheckbox(
              label: 'Signature / Digital Signature / सही / डिजिटल स्वाक्षरी',
              value: _hasSignature,
              onChanged: (v) => setState(() => _hasSignature = v ?? false),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                        : const Text('Preview Form / फॉर्मचे पूर्वावलोकन', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? hint,
    TextInputType? keyboardType,
    String? prefix,
    bool required = false,
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

  Widget _buildTextArea({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool required = false,
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
            if (required) ...[
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
            ],
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
    if (label.contains('Owner Sub-caste')) {
      otherController = _ownerSubcasteOtherController;
    } else if (label.contains('Gender')) {
      otherController = _ownerGenderOtherController;
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
                  if (label.contains('Business Structure')) _businessStructure = v;
                  else if (label.contains('Owner Sub-caste')) {
                    _ownerSubcaste = v;
                    if (v == null || !(v.contains('Other') || v.contains('इतर'))) {
                      _ownerSubcasteOtherController.clear();
                    }
                  } else if (label.contains('Gender')) {
                    _ownerGender = v;
                    if (v == null || !(v.contains('Other') || v.contains('इतर'))) {
                      _ownerGenderOtherController.clear();
                    }
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
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 4),
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
        GestureDetector(
          onTap: uploading ? null : onTap,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.pink.shade200, width: 2, style: BorderStyle.solid),
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
                    ? ClipOval(
                        child: Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _circularPhotoPlaceholder(),
                        ),
                      )
                    : _circularPhotoPlaceholder(),
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
                          errorBuilder: (_, __, ___) => _rectangularPhotoPlaceholder(),
                        ),
                      )
                    : _rectangularPhotoPlaceholder(),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: uploading ? null : onTap,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.pink.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Choose file', style: TextStyle(fontSize: 14)),
          ),
        ),
        Text(
          photoUrl != null ? 'File chosen' : 'No file chosen',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildWorkingHoursDay(String day, String label) {
    final isEnabled = _workingHours[day]!['enabled'] as bool;
    final from = _workingHours[day]!['from'] as String;
    final to = _workingHours[day]!['to'] as String;

    return Row(
      children: [
        Checkbox(
          value: isEnabled,
          onChanged: (v) {
            setState(() {
              _workingHours[day]!['enabled'] = v ?? false;
              if (!(v ?? false)) {
                _workingHours[day]!['from'] = '';
                _workingHours[day]!['to'] = '';
              } else {
                if (day == 'saturday') {
                  _workingHours[day]!['from'] = '10:00 AM';
                  _workingHours[day]!['to'] = '06:00 PM';
                } else {
                  _workingHours[day]!['from'] = '10:00 AM';
                  _workingHours[day]!['to'] = '08:00 PM';
                }
              }
            });
          },
          activeColor: AppTheme.gold,
        ),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
          ),
        ),
        if (isEnabled) ...[
          Expanded(
            child: _buildTimeField(
              label: 'From / पासून',
              value: from,
              onTap: () => _pickTime(context, day, 'from'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTimeField(
              label: 'To / पर्यंत',
              value: to,
              onTap: () => _pickTime(context, day, 'to'),
            ),
          ),
        ] else
          Expanded(
            flex: 2,
            child: Text(
              'Closed / बंद',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? '--:-- --' : value,
                    style: TextStyle(
                      fontSize: 13,
                      color: value.isEmpty ? Colors.grey.shade500 : Colors.grey.shade800,
                    ),
                  ),
                ),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
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
                                  if (label.contains('Aadhaar')) _ownersAadhaarImageUrl = null;
                                  else if (label.contains('PAN')) _ownersPanCardImageUrl = null;
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

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.gold,
        ),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
          ),
        ),
      ],
    );
  }

  Widget _circularPhotoPlaceholder() {
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

  Widget _rectangularPhotoPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Image Preview',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
