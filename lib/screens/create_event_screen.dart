import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../payment_config.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/image_picker_service.dart';
import 'payment_screen.dart';

/// Event Registration Form — comprehensive form matching screenshots exactly.
class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  // Event Banner
  String? _bannerUrl;
  bool _uploadingBanner = false;

  // Form Fields
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _cityController = TextEditingController();
  final _venueAddressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _organizerNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _ticketAmountController = TextEditingController();

  // Event Type
  String _eventType = 'free';

  bool _loading = false;
  bool _checkingPayment = false;

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _cityController.dispose();
    _venueAddressController.dispose();
    _descriptionController.dispose();
    _organizerNameController.dispose();
    _contactNumberController.dispose();
    _ticketAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
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
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> _pickTime() async {
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
      final hour = picked.hour;
      final minute = picked.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      _timeController.text = '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    }
  }

  Future<String?> _uploadBanner() async {
    return await ImagePickerService.instance.pickAndUploadImage(
      context: context,
      storagePath: 'events/${FirebaseAuthService.instance.currentUser?.uid ?? 'unknown'}/banner',
      maxWidth: 1920,
      maxHeight: 1080,
      successMessage: 'Banner uploaded successfully.',
      errorMessage: 'Upload failed. Please try again.',
    );
  }

  Future<bool> _checkEventPaymentValidity() async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) return false;
    return await FirestoreService.instance.hasValidPaymentForFeature(user.uid, PaymentConfig.events);
  }

  Future<void> _onSubmit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter event title')),
      );
      return;
    }
    if (_eventType == 'paid') {
      final ticketAmount = _ticketAmountController.text.trim();
      if (ticketAmount.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter ticket amount for paid event')),
        );
        return;
      }
      final amount = int.tryParse(ticketAmount);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid ticket amount')),
        );
        return;
      }
    }
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in')));
      return;
    }

    // Check payment validity for event creation
    setState(() => _checkingPayment = true);
    final hasValidPayment = await _checkEventPaymentValidity();
    setState(() => _checkingPayment = false);
    
    if (!hasValidPayment) {
      if (!mounted) return;
      final shouldPay = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Payment Required'),
          content: Text(
            'To create events, you need to pay ₹${PaymentConfig.eventsAmount} for 24 hours validity.\n\nDo you want to proceed with payment?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.gold),
              child: const Text('Pay Now'),
            ),
          ],
        ),
      );
      if (shouldPay == true && mounted) {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentScreen(featureId: PaymentConfig.events),
          ),
        );
        if (result != true || !mounted) return;
        // Re-check payment validity after payment
        setState(() => _checkingPayment = true);
        final hasValidPaymentAfter = await _checkEventPaymentValidity();
        setState(() => _checkingPayment = false);
        if (!hasValidPaymentAfter) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment verification failed. Please try again.')),
            );
          }
          return;
        }
      } else {
        return;
      }
    }

    final profile = await FirestoreService.instance.getUserProfile(user.uid);
    final createdBy = profile?['displayName'] as String? ?? user.displayName ?? user.email ?? user.phoneNumber;
    setState(() => _loading = true);
    try {
      final ticketAmount = _eventType == 'paid' && _ticketAmountController.text.trim().isNotEmpty
          ? int.tryParse(_ticketAmountController.text.trim())
          : null;
      await FirestoreService.instance.addEvent(
        userId: user.uid,
        title: title,
        bannerUrl: _bannerUrl,
        date: _dateController.text.trim().isEmpty ? null : _dateController.text.trim(),
        time: _timeController.text.trim().isEmpty ? null : _timeController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        venueAddress: _venueAddressController.text.trim().isEmpty ? null : _venueAddressController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        organizerName: _organizerNameController.text.trim().isEmpty ? null : _organizerNameController.text.trim(),
        contactNumber: _contactNumberController.text.trim().isEmpty ? null : _contactNumberController.text.trim(),
        createdBy: createdBy,
        eventType: _eventType,
        ticketAmount: ticketAmount,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully. It will appear on Home.'), backgroundColor: Colors.green),
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
          'Create New Event / नवीन कार्यक्रम तयार करा',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Banner Upload
            Text(
              'Event Banner / कार्यक्रमाचा बॅनर',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _uploadingBanner
                  ? null
                  : () async {
                      setState(() => _uploadingBanner = true);
                      final url = await _uploadBanner();
                      setState(() {
                        _uploadingBanner = false;
                        if (url != null) _bannerUrl = url;
                      });
                    },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  border: Border.all(color: Colors.pink.shade200, width: 2, style: BorderStyle.solid),
                ),
                child: _uploadingBanner
                    ? const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (_bannerUrl != null && _bannerUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                            child: Image.network(
                              _bannerUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _bannerPlaceholder(),
                            ),
                          )
                        : _bannerPlaceholder(),
              ),
            ),
            const SizedBox(height: 32),

            // Event Title and Date (Two columns)
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Event Title / कार्यक्रमाचे नाव',
                    controller: _titleController,
                    hint: 'e.g. Annual Gathering',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Date / तारीख',
                    controller: _dateController,
                    hint: 'dd/mm/yyyy',
                    readOnly: true,
                    onTap: _pickDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time and City (Two columns)
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Time / वेळ',
                    controller: _timeController,
                    hint: '--:-- --',
                    readOnly: true,
                    onTap: _pickTime,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'City / शहर',
                    controller: _cityController,
                    hint: 'e.g. Pune',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Venue Address (Full width)
            _buildTextField(
              label: 'Venue Address / ठिकाण',
              controller: _venueAddressController,
              hint: 'e.g. Balgandharva Rangmandir',
            ),
            const SizedBox(height: 16),

            // Description (Full width, textarea)
            _buildTextArea(
              label: 'Description / वर्णन',
              controller: _descriptionController,
              hint: 'Describe the event details...',
            ),
            const SizedBox(height: 16),

            // Organizer Name and Contact Number (Two columns)
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Organizer Name / आयोजकाचे नाव',
                    controller: _organizerNameController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Contact Number / संपर्क क्रमांक',
                    controller: _contactNumberController,
                    keyboardType: TextInputType.phone,
                    prefix: '+91 ',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Event Type Selection
            _buildDropdown(
              label: 'Event Type / कार्यक्रम प्रकार',
              value: _eventType,
              items: const ['free', 'paid'],
              onChanged: (value) {
                setState(() {
                  _eventType = value ?? 'free';
                  if (_eventType == 'free') {
                    _ticketAmountController.clear();
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Ticket Amount (only for paid events)
            if (_eventType == 'paid')
              _buildTextField(
                label: 'Ticket Amount (₹) / तिकीट रक्कम (₹)',
                controller: _ticketAmountController,
                keyboardType: TextInputType.number,
                hint: 'e.g. 500',
              ),
            if (_eventType == 'paid') const SizedBox(height: 16),

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
                        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                      ),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
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
                    child: (_loading || _checkingPayment)
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Create Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    String? prefix,
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
              borderSide: BorderSide(color: Colors.pink.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: Colors.pink.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: Colors.pink.shade400, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: Colors.pink.shade200),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: Colors.pink.shade200),
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
    required String value,
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
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            border: Border.all(color: Colors.pink.shade200),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: items.map((item) {
              final displayText = item == 'free' ? 'Free / मोफत' : 'Paid / पेड';
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  displayText,
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            dropdownColor: Colors.white,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required String label,
    required TextEditingController controller,
    String? hint,
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
        TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: Colors.pink.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: Colors.pink.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: Colors.pink.shade400, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: Colors.pink.shade200),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: Colors.pink.shade200),
            ),
            errorStyle: const TextStyle(height: 0, fontSize: 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _bannerPlaceholder() {
    return Center(
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
              style: TextStyle(fontSize: 12, color: Colors.pink.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
