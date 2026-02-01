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
    final whatsappNumber = _orDash(_str(profile['whatsappNumber']));
    final email = _orDash(_str(profile['email']));
    final dateOfBirth = _orDash(_str(profile['dateOfBirth']));
    final age = _orDash(_str(profile['age']));
    final birthTime = _orDash(_str(profile['birthTime']));
    final birthPlace = _orDash(_str(profile['birthPlace']));
    final height = _orDash(_str(profile['height']));
    final weight = _orDash(_str(profile['weight']));
    final complexion = _orDash(_str(profile['complexion']));
    final bloodGroup = _orDash(_str(profile['bloodGroup']));
    final diet = _orDash(_str(profile['diet']));
    final manglik = _orDash(_str(profile['manglik']));
    final nakshatra = _orDash(_str(profile['nakshatra']));
    final rashi = _orDash(_str(profile['rashi']));
    final gotra = _orDash(_str(profile['gotra']));
    final maritalStatus = _orDash(_str(profile['maritalStatus']));
    final disability = _orDash(_str(profile['disability']));
    final education = _orDash(_str(profile['education']));
    final occupation = _orDash(_str(profile['occupation']));
    final subcaste = _orDash(_str(profile['subcaste']));
    final district = _orDash(_str(profile['district']));
    final state = _orDash(_str(profile['state']));
    final country = _orDash(_str(profile['country']));
    final familyValues = _orDash(_str(profile['familyValues']));
    final financialOutlook = _orDash(_str(profile['financialOutlook']));
    final communicationStyle = _orDash(_str(profile['communicationStyle']));
    final hobbiesInterests = _orDash(_str(profile['hobbiesInterests']));
    final lifeGoals = _orDash(_str(profile['lifeGoals']));
    final expectedEducation = _orDash(_str(profile['expectedEducation']));
    final expectedOccupation = _orDash(_str(profile['expectedOccupation']));
    final expectedHeight = _orDash(_str(profile['expectedHeight']));
    final expectedFamilyValues = _orDash(_str(profile['expectedFamilyValues']));
    final expectedFinancialOutlook = _orDash(_str(profile['expectedFinancialOutlook']));
    final expectedCommunicationStyle = _orDash(_str(profile['expectedCommunicationStyle']));
    final otherExpectations = _orDash(_str(profile['otherExpectations']));

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
            // Personal Information Section
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
                    _sectionHeader('Personal Information / वैयक्तिक माहिती'),
                    _row('Full Name / मुलाचे पूर्ण नाव', name),
                    _row('Date of Birth / जन्मतारीख', dateOfBirth),
                    _row('Age / वय', age),
                    _row('Birth Time / जन्म वेळ', birthTime),
                    _row('Birth Place / जन्मस्थान', birthPlace),
                    _row('Height / उंची', height),
                    _row('Weight / वजन', weight),
                    _row('Complexion / रंग', complexion),
                    _row('Blood Group / रक्तगट', bloodGroup),
                    _row('Diet / आहार', diet),
                    _row('Marital Status / वैवाहिक स्थिती', maritalStatus),
                    _row('Disability / अपंगत्व', disability),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Astrological Information
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Astrological Information / ज्योतिषीय माहिती'),
                    _row('Manglik / मंगळिक', manglik),
                    _row('Nakshatra / नक्षत्र', nakshatra),
                    _row('Rashi / राशी', rashi),
                    _row('Gotra / गोत्र', gotra),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Contact & Education
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Contact & Education / संपर्क आणि शिक्षण'),
                    _row('Phone / मोबाईल नंबर', phone),
                    _row('WhatsApp / व्हॉट्सऍप', whatsappNumber),
                    _row('Email / ईमेल आयडी', email),
                    _row('Education / शिक्षण', education),
                    _row('Occupation / व्यवसाय / नोकरी', occupation),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Location
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Location / स्थान'),
                    _row('Sub Caste / पोटजात', subcaste),
                    _row('District / जिल्हा', district),
                    _row('State / राज्य', state),
                    _row('Country / देश', country),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Lifestyle
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Lifestyle / जीवनशैली'),
                    _row('Family Values / कौटुंबिक मूल्ये', familyValues),
                    _row('Financial Outlook / आर्थिक दृष्टिकोन', financialOutlook),
                    _row('Communication Style / संवाद शैली', communicationStyle),
                    if (hobbiesInterests.isNotEmpty && hobbiesInterests != '—')
                      _row('Hobbies & Interests / छंद आणि आवडी', hobbiesInterests),
                    if (lifeGoals.isNotEmpty && lifeGoals != '—')
                      _row('Life Goals / जीवनाची ध्येये', lifeGoals),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Partner Preferences
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Partner Preferences / जोडीदाराविषयी अपेक्षा'),
                    _row('Expected Education / अपेक्षित शिक्षण', expectedEducation),
                    _row('Expected Occupation / अपेक्षित व्यवसाय', expectedOccupation),
                    _row('Expected Height / अपेक्षित उंची', expectedHeight),
                    _row('Expected Family Values / अपेक्षित कौटुंबिक मूल्ये', expectedFamilyValues),
                    _row('Expected Financial Outlook / अपेक्षित आर्थिक दृष्टिकोन', expectedFinancialOutlook),
                    _row('Expected Communication Style / अपेक्षित संवाद शैली', expectedCommunicationStyle),
                    if (otherExpectations.isNotEmpty && otherExpectations != '—')
                      _row('Other Expectations / इतर अपेक्षा', otherExpectations),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Family Members
            if (familyList.isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('Family Details / कौटुंबिक माहिती'),
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
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
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
