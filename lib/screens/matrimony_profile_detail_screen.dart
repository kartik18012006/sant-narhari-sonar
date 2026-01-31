import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Full matrimony profile — shows all fields the user filled in the registration form.
/// Opened from search results after payment; filters applied on list screen.
class MatrimonyProfileDetailScreen extends StatelessWidget {
  const MatrimonyProfileDetailScreen({super.key, required this.profile});

  final Map<String, dynamic> profile;

  static String _str(dynamic v) => v == null ? '' : v.toString().trim();
  static String _orDash(String s) => s.isEmpty ? '—' : s;

  Widget _buildProfileAvatar(Map<String, dynamic> profile, String name) {
    final photoUrl = profile['photoUrl'] as String?;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          photoUrl,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _avatarFallback(name),
        ),
      );
    }
    return _avatarFallback(name);
  }

  Widget _avatarFallback(String name) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
      child: Text(
        name.isNotEmpty && name != '—' ? name.substring(0, 1).toUpperCase() : '?',
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.gold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = _str(profile['type']);
    final isGroom = type == 'groom';
    final name = _orDash(_str(profile['name']));
    final phone = _orDash(_str(profile['phone']));
    final email = _orDash(_str(profile['email']));
    final education = _orDash(_str(profile['education']));
    final occupation = _orDash(_str(profile['occupation']));
    final subcaste = _orDash(_str(profile['subcaste']));
    final maritalStatus = _orDash(_str(profile['maritalStatus']));
    final city = _orDash(_str(profile['city']));

    final rawFamily = profile['familyMembers'];
    final List<Map<String, dynamic>> familyList = rawFamily is List
        ? rawFamily
            .where((e) => e is Map)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList()
        : <Map<String, dynamic>>[];

    final title = isGroom ? 'Groom Profile / वर प्रोफाइल' : 'Bride Profile / वधू प्रोफाइल';

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
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: _buildProfileAvatar(profile, name),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _row('Full Name / मुलाचे पूर्ण नाव', name),
                    _row('Marital Status / वैवाहिक स्थिती', maritalStatus),
                    _row('Sub Caste / पोटजात', subcaste),
                    _row('Phone / मोबाईल नंबर', phone),
                    _row('Email / ईमेल आयडी', email),
                    _row('Education / शिक्षण', education),
                    _row('Occupation / व्यवसाय / नोकरी', occupation),
                    _row('City / शहर', city),
                    if (familyList.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Family Details / कौटुंबिक माहिती',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 12),
                      ...familyList.map((m) {
                        final fn = _orDash(_str(m['name']));
                        final memberNumber = _orDash(_str(m['number']));
                        final rel = _orDash(_str(m['relation']));
                        final age = _orDash(_str(m['age']));
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fn, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                                if (rel.isNotEmpty && rel != '—') _smallRow('Relation / नाते', rel),
                                if (memberNumber.isNotEmpty && memberNumber != '—') _smallRow('Number / नंबर', memberNumber),
                                if (age.isNotEmpty && age != '—') _smallRow('Age / वय', age),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    final display = value.isEmpty ? '—' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            display,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
