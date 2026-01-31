import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

/// List Event form — after payment. Matches APK exactly: title, date & time, location, description, gold styling.
class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ticketAmountController = TextEditingController();
  String _eventType = 'free'; // 'free' or 'paid'
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _ticketAmountController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    if (_eventType == 'paid') {
      final amountStr = _ticketAmountController.text.trim();
      if (amountStr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter entry ticket amount for paid event')));
        return;
      }
      final amount = num.tryParse(amountStr);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid ticket amount (e.g. 100)')));
        return;
      }
    }
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in')));
      return;
    }
    setState(() => _loading = true);
    try {
      final profile = await FirestoreService.instance.getUserProfile(user.uid);
      final ticketAmount = _eventType == 'paid' ? num.tryParse(_ticketAmountController.text.trim()) : null;
      await FirestoreService.instance.addEvent(
        userId: user.uid,
        title: title,
        date: _dateController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        createdBy: profile?['displayName'] as String? ?? user.displayName ?? user.email ?? user.phoneNumber,
        eventType: _eventType,
        ticketAmount: _eventType == 'paid' ? ticketAmount : null,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event listed. It will appear on Home.'), backgroundColor: Colors.green));
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
          'List Event / कार्यक्रम सूची',
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
              'Create an event for the Sonar community. It will appear under Upcoming Events on Home.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            _label('Title *'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration('e.g. Annual Sonar Samaj Gathering'),
            ),
            const SizedBox(height: 16),
            _label('Date & time'),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: _inputDecoration('e.g. Friday, 15 August 2025 at 10:00 AM'),
            ),
            const SizedBox(height: 16),
            _label('Location'),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: _inputDecoration('e.g. Santosh Bhavan, Pune'),
            ),
            const SizedBox(height: 16),
            _label('Event type / कार्यक्रम प्रकार'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _eventTypeChip('Free', 'free', 'मोफत'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _eventTypeChip('Paid', 'paid', 'पैसे देय'),
                ),
              ],
            ),
            if (_eventType == 'paid') ...[
              const SizedBox(height: 16),
              _label('Entry ticket amount (₹) * / प्रवेश तिकीट रक्कम (₹) *'),
              const SizedBox(height: 8),
              TextField(
                controller: _ticketAmountController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('e.g. 100, 500'),
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 16),
            _label('Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _inputDecoration('Event details, agenda...'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: AppTheme.buttonHeight,
              child: FilledButton(
                onPressed: _loading ? null : _onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                ),
                child: _loading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('List Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventTypeChip(String labelEn, String value, String labelMr) {
    final selected = _eventType == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _eventType = value),
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.gold.withValues(alpha: 0.15) : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            border: Border.all(
              color: selected ? AppTheme.gold : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                value == 'free' ? Icons.check_circle_outline : Icons.paid_outlined,
                size: 20,
                color: selected ? AppTheme.gold : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$labelEn / $labelMr',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? AppTheme.gold : Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
