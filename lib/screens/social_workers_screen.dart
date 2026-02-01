import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firestore_service.dart';
import 'social_worker_terms_screen.dart';

/// Social Workers — register, search and filter by location & subcaste. Matches APK exactly.
class SocialWorkersScreen extends StatefulWidget {
  const SocialWorkersScreen({super.key});

  @override
  State<SocialWorkersScreen> createState() => _SocialWorkersScreenState();
}

class _SocialWorkersScreenState extends State<SocialWorkersScreen> {
  final _searchController = TextEditingController();
  String? _place;
  String? _subcaste;

  /// Place options for location filter (cities/districts).
  static const List<String> _placeOptions = ['Pune', 'Mumbai', 'Nagpur', 'Nashik', 'Kolhapur', 'Sangli', 'Other'];
  static List<String> get _subcasteOptions => AppTheme.subcasteOptions;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> list) {
    var result = list;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((s) {
        final name = (s['name'] as String? ?? '').toLowerCase();
        final phone = (s['phone'] as String? ?? '').toString();
        final email = (s['email'] as String? ?? '').toLowerCase();
        final specialization = (s['specialization'] as String? ?? '').toLowerCase();
        final organization = (s['organization'] as String? ?? '').toLowerCase();
        final address = (s['address'] as String? ?? '').toLowerCase();
        return name.contains(query) ||
            phone.contains(query) ||
            email.contains(query) ||
            specialization.contains(query) ||
            organization.contains(query) ||
            address.contains(query);
      }).toList();
    }
    if (_place != null && _place!.isNotEmpty) {
      result = result.where((s) {
        final permanentCity = (s['permanentVillageCity'] as String? ?? '').toLowerCase();
        final permanentDistrict = (s['permanentDistrict'] as String? ?? '').toLowerCase();
        final permanentState = (s['permanentState'] as String? ?? '').toLowerCase();
        final currentCity = (s['currentVillageCity'] as String? ?? '').toLowerCase();
        final currentDistrict = (s['currentDistrict'] as String? ?? '').toLowerCase();
        final currentState = (s['currentState'] as String? ?? '').toLowerCase();
        final placeLower = _place!.toLowerCase();
        return permanentCity.contains(placeLower) ||
            permanentDistrict.contains(placeLower) ||
            permanentState.contains(placeLower) ||
            currentCity.contains(placeLower) ||
            currentDistrict.contains(placeLower) ||
            currentState.contains(placeLower) ||
            permanentCity == placeLower ||
            permanentDistrict == placeLower ||
            permanentState == placeLower ||
            currentCity == placeLower ||
            currentDistrict == placeLower ||
            currentState == placeLower;
      }).toList();
    }
    if (_subcaste != null && _subcaste!.isNotEmpty) {
      result = result.where((s) {
        final sc = s['subcaste'] as String? ?? '';
        return sc == _subcaste;
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
          'Social Worker / सामाजिक कार्यकर्ता',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey.shade800),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
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
                      'Register as Social Worker / समाजसेवक म्हणून नोंदणी करा',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search Social Workers / सामाजिक कार्यकर्ता शोधा',
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
                _dropdown(
                  label: 'Place / स्थान',
                  value: _place,
                  hint: 'Select city or district',
                  items: _placeOptions,
                  onChanged: (v) => setState(() => _place = v),
                ),
                const SizedBox(height: 12),
                _dropdown(
                  label: 'Subcaste / पोटजात',
                  value: _subcaste,
                  hint: 'Select subcaste',
                  items: _subcasteOptions,
                  onChanged: (v) => setState(() => _subcaste = v),
                ),
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
              stream: FirestoreService.instance.streamSocialWorkersApproved(),
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
                          Icon(Icons.volunteer_activism, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            list.isEmpty ? 'No social workers yet' : 'No social workers match your filters',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
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
                    final s = filtered[index];
                    final name = s['name'] as String? ?? '—';
                    final photoUrl = s['photoUrl'] as String?;
                    final specialization = s['specialization'] as String? ?? '';
                    final organization = s['organization'] as String? ?? '';
                    final address = s['address'] as String? ?? '';
                    final phone = s['phone'] as String? ?? '';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
                          backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null || photoUrl.isEmpty
                              ? Text(
                                  name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                                  style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          [specialization, organization, address, phone].where((e) => e.isNotEmpty).join(' • '),
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
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _FilterSheetContent(
        initialPlace: _place,
        initialSubcaste: _subcaste,
        placeOptions: _placeOptions,
        subcasteOptions: _subcasteOptions,
        dropdownBuilder: _dropdown,
        onClear: () {
          _clearFilters();
          Navigator.of(ctx).pop();
        },
        onApply: (place, subcaste) {
          setState(() {
            _place = place;
            _subcaste = subcaste;
          });
          Navigator.of(ctx).pop();
        },
      ),
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
              hint: Text(hint, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _onRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SocialWorkerTermsScreen(),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _place = null;
      _subcaste = null;
      _searchController.clear();
    });
  }
}

class _FilterSheetContent extends StatefulWidget {
  const _FilterSheetContent({
    required this.initialPlace,
    required this.initialSubcaste,
    required this.placeOptions,
    required this.subcasteOptions,
    required this.dropdownBuilder,
    required this.onClear,
    required this.onApply,
  });

  final String? initialPlace;
  final String? initialSubcaste;
  final List<String> placeOptions;
  final List<String> subcasteOptions;
  final Widget Function({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) dropdownBuilder;
  final VoidCallback onClear;
  final void Function(String? place, String? subcaste) onApply;

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  late String? _place;
  late String? _subcaste;

  @override
  void initState() {
    super.initState();
    _place = widget.initialPlace;
    _subcaste = widget.initialSubcaste;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filters / फिल्टर',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 16),
          widget.dropdownBuilder(
            label: 'Place / स्थान',
            value: _place,
            hint: 'Select city or district',
            items: widget.placeOptions,
            onChanged: (v) => setState(() => _place = v),
          ),
          const SizedBox(height: 12),
          widget.dropdownBuilder(
            label: 'Subcaste / पोटजात',
            value: _subcaste,
            hint: 'Select subcaste',
            items: widget.subcasteOptions,
            onChanged: (v) => setState(() => _subcaste = v),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClear,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                  ),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => widget.onApply(_place, _subcaste),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
