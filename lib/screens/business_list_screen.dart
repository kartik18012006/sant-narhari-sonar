import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../payment_config.dart';
import '../services/firestore_service.dart';
import 'business_registration_screen.dart';
import 'payment_screen.dart';

/// Business directory — search by subcaste / place / business nature. Lists approved businesses.
/// "Register your business" opens payment then registration form.
class BusinessListScreen extends StatefulWidget {
  const BusinessListScreen({super.key});

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  final _searchController = TextEditingController();
  String? _subcaste;
  String? _place;
  String? _businessNature;

  static List<String> get _subcasteOptions => AppTheme.subcasteOptions;
  static List<String> get _placeOptions => AppTheme.businessPlaceOptions;
  static List<String> get _natureOptions => AppTheme.businessNatureOptions;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> list) {
    var result = list;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((b) {
        final name = (b['businessName'] as String? ?? '').toLowerCase();
        final desc = (b['description'] as String? ?? '').toLowerCase();
        final address = (b['address'] as String? ?? '').toLowerCase();
        final contact = (b['contact'] as String? ?? '').toString().toLowerCase();
        return name.contains(query) ||
            desc.contains(query) ||
            address.contains(query) ||
            contact.contains(query);
      }).toList();
    }
    if (_subcaste != null && _subcaste!.isNotEmpty) {
      result = result.where((b) {
        final sc = b['subcaste'] as String? ?? '';
        return sc == _subcaste;
      }).toList();
    }
    if (_place != null && _place!.isNotEmpty) {
      result = result.where((b) {
        final p = b['place'] as String? ?? '';
        return p == _place;
      }).toList();
    }
    if (_businessNature != null && _businessNature!.isNotEmpty) {
      result = result.where((b) {
        final n = b['businessNature'] as String? ?? '';
        return n == _businessNature;
      }).toList();
    }
    return result;
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
          'Business Directory / व्यवसाय निर्देशिका',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search subcaste / place / business nature',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.gold, size: 22),
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
                  ),
                ),
                const SizedBox(height: 14),
                _dropdown('Subcaste / पोटजात', _subcaste, _subcasteOptions, (v) => setState(() => _subcaste = v)),
                const SizedBox(height: 12),
                _dropdown('Place / स्थान', _place, _placeOptions, (v) => setState(() => _place = v)),
                const SizedBox(height: 12),
                _dropdown('Business Nature / व्यवसाय प्रकार', _businessNature, _natureOptions, (v) => setState(() => _businessNature = v)),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _clearFilters,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Clear filters',
                      style: TextStyle(fontSize: 13, color: AppTheme.gold, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService.instance.streamBusinessesApproved(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }
                final list = snapshot.data ?? [];
                final filtered = _applyFilters(list);
                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            list.isEmpty
                                ? 'No businesses listed yet.'
                                : 'No businesses match your filters.',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final b = filtered[index];
                    final name = b['businessName'] as String? ?? '—';
                    final desc = b['description'] as String? ?? '';
                    final place = b['place'] as String? ?? '';
                    final nature = b['businessNature'] as String? ?? '';
                    final contact = b['contact'] as String? ?? '';
                    final subtitle = [nature, place, contact].where((e) => e.isNotEmpty).join(' • ');
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
                          child: const Icon(Icons.business, color: AppTheme.gold, size: 24),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          desc.isNotEmpty ? desc : subtitle,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade500),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            height: AppTheme.buttonHeight,
            child: FilledButton(
              onPressed: _onRegister,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
              ),
              child: const Text(
                'Register your business / व्यवसाय नोंदवा',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
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
              hint: Text('Select... / निवडा...', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _subcaste = null;
      _place = null;
      _businessNature = null;
      _searchController.clear();
    });
  }

  void _onRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => PaymentScreen(
          featureId: PaymentConfig.businessRegistration,
          amount: PaymentConfig.businessRegistrationAmount,
        ),
      ),
    ).then((paid) {
      if (paid == true && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BusinessRegistrationScreen()),
        );
      }
    });
  }
}
