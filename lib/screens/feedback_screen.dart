import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/image_picker_service.dart';

/// User feedback screen with name, type, and file attachment. Submissions go to Firestore; admin can view in Admin Panel.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _nameController = TextEditingController();
  final _feedbackController = TextEditingController();
  String? _feedbackType;
  String? _attachmentUrl;
  bool _uploadingAttachment = false;
  bool _sending = false;
  bool _sent = false;

  static const List<String> _feedbackTypes = [
    'Bug Report / त्रुटी अहवाल',
    'Feature Request / वैशिष्ट्य विनंती',
    'General Feedback / सामान्य अभिप्राय',
    'Complaint / तक्रार',
    'Suggestion / सूचना',
    'Other / इतर',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _uploadAttachment() async {
    setState(() => _uploadingAttachment = true);
    try {
      final user = FirebaseAuthService.instance.currentUser;
      final url = await ImagePickerService.instance.pickAndUploadImage(
        context: context,
        storagePath: 'feedback/${user?.uid ?? 'unknown'}/${DateTime.now().millisecondsSinceEpoch}',
        maxWidth: 2048,
        maxHeight: 2048,
        successMessage: 'File uploaded successfully.',
      );
      if (mounted) {
        setState(() {
          _attachmentUrl = url;
          _uploadingAttachment = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingAttachment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final text = _feedbackController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    
    if (_feedbackType == null || _feedbackType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select type of feedback')),
      );
      return;
    }
    
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
      return;
    }
    
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to send feedback')),
        );
      }
      return;
    }
    setState(() => _sending = true);
    try {
      final profile = await FirestoreService.instance.getUserProfile(user.uid);
      await FirestoreService.instance.addFeedback(
        userId: user.uid,
        text: text,
        userEmail: user.email,
        userDisplayName: name.isNotEmpty ? name : (profile?['displayName'] as String? ?? user.displayName),
        feedbackType: _feedbackType,
        attachmentUrl: _attachmentUrl,
      );
      if (mounted) {
        setState(() {
          _sending = false;
          _sent = true;
        });
        _nameController.clear();
        _feedbackController.clear();
        setState(() {
          _feedbackType = null;
          _attachmentUrl = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your feedback has been submitted.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save feedback: $e')),
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
          'Suggestions & Feedback / सूचना आणि अभिप्राय',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Send your feedback or report an issue. The admin team will review it.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 20),
            _label('Your Name / तुमचे नाव'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              enabled: !_sending && !_sent,
              decoration: InputDecoration(
                hintText: 'Enter your name',
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
            _label('Type of Feedback / अभिप्रायाचा प्रकार'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonFormField<String>(
                value: _feedbackType,
                decoration: InputDecoration(
                  hintText: 'Select type of feedback',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                items: _feedbackTypes.map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (_sending || _sent) ? null : (value) {
                  setState(() => _feedbackType = value);
                },
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 20),
            _label('Attach Screenshot or File (Optional) / स्क्रीनशॉट किंवा फाइल जोडा (पर्यायी)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: (_uploadingAttachment || _sending || _sent) ? null : _uploadAttachment,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                  border: Border.all(
                    color: _attachmentUrl != null ? AppTheme.gold : Colors.grey.shade300,
                    width: _attachmentUrl != null ? 2 : 1,
                  ),
                ),
                child: _uploadingAttachment
                    ? const Center(child: CircularProgressIndicator())
                    : _attachmentUrl != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                                child: Image.network(
                                  _attachmentUrl!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.attach_file, size: 48),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: (_sending || _sent) ? null : () {
                                    setState(() => _attachmentUrl = null);
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black54,
                                    padding: const EdgeInsets.all(4),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.attach_file, size: 32, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to attach file',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 20),
            _label('Your Feedback / तुमचा अभिप्राय'),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 6,
              enabled: !_sending && !_sent,
              decoration: InputDecoration(
                hintText: 'Enter your feedback...',
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
            const SizedBox(height: 24),
            SizedBox(
              height: AppTheme.buttonHeight,
              child: FilledButton(
                onPressed: (_sending || _sent) ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  ),
                ),
                child: _sending
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _sent ? 'Submitted' : 'Submit Feedback / अभिप्राय सबमिट करा',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
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
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }
}
