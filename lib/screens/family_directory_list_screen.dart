import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firestore_service.dart';

/// Family Directory list — search and filter by Village & Relation. Shown after payment. Matches APK exactly.
class FamilyDirectoryListScreen extends StatefulWidget {
  const FamilyDirectoryListScreen({super.key});

  @override
  State<FamilyDirectoryListScreen> createState() => _FamilyDirectoryListScreenState();
}

class _FamilyDirectoryListScreenState extends State<FamilyDirectoryListScreen> {
  final _searchController = TextEditingController();
  String? _village;
  String? _relation;

  static const List<String> _relationOptions = ['Father', 'Mother', 'Sibling', 'Spouse', 'Grandparent', 'Other'];
  static const List<String> _villageOptions = ['Pune', 'Mumbai', 'Nagpur', 'Nashik', 'Kolhapur', 'Sangli', 'Other'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> list) {
    var result = list;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((m) {
        final name = (m['name'] as String? ?? '').toLowerCase();
        final relation = (m['relation'] as String? ?? '').toLowerCase();
        final village = (m['village'] as String? ?? '').toLowerCase();
        final contact = (m['contact'] as String? ?? '').toString();
        return name.contains(query) ||
            relation.contains(query) ||
            village.contains(query) ||
            contact.contains(query);
      }).toList();
    }
    if (_village != null && _village!.isNotEmpty) {
      result = result.where((m) {
        final v = m['village'] as String? ?? '';
        return v == _village || v.toLowerCase().contains(_village!.toLowerCase());
      }).toList();
    }
    if (_relation != null && _relation!.isNotEmpty) {
      result = result.where((m) {
        final r = m['relation'] as String? ?? '';
        return r == _relation;
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
          'Family Directory / कुटुंब निर्देशिका',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
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
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search Family Directory / कुटुंब निर्देशिका शोधा',
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
                  label: 'Village / City / गाव',
                  value: _village,
                  hint: 'Select village or city',
                  items: _villageOptions,
                  onChanged: (v) => setState(() => _village = v),
                ),
                const SizedBox(height: 12),
                _dropdown(
                  label: 'Relation / नाते',
                  value: _relation,
                  hint: 'Select relation',
                  items: _relationOptions,
                  onChanged: (v) => setState(() => _relation = v),
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
              stream: FirestoreService.instance.streamFamilyDirectoryApproved(),
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
                          Icon(Icons.family_restroom, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            list.isEmpty ? 'No family directory entries yet' : 'No entries match your filters',
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
                    final m = filtered[index];
                    final name = m['name'] as String? ?? '—';
                    final relation = m['relation'] as String? ?? '';
                    final village = m['village'] as String? ?? '';
                    final contact = m['contact'] as String? ?? '';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
                          child: Text(
                            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                            style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          [relation, village, contact].where((e) => e.isNotEmpty).join(' • '),
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
      builder: (ctx) => _FamilyFilterSheet(
        initialVillage: _village,
        initialRelation: _relation,
        villageOptions: _villageOptions,
        relationOptions: _relationOptions,
        onClear: () {
          _clearFilters();
          Navigator.of(ctx).pop();
        },
        onApply: (village, relation) {
          setState(() {
            _village = village;
            _relation = relation;
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

  void _clearFilters() {
    setState(() {
      _village = null;
      _relation = null;
      _searchController.clear();
    });
  }
}

class _FamilyFilterSheet extends StatefulWidget {
  const _FamilyFilterSheet({
    required this.initialVillage,
    required this.initialRelation,
    required this.villageOptions,
    required this.relationOptions,
    required this.onClear,
    required this.onApply,
  });

  final String? initialVillage;
  final String? initialRelation;
  final List<String> villageOptions;
  final List<String> relationOptions;
  final VoidCallback onClear;
  final void Function(String? village, String? relation) onApply;

  @override
  State<_FamilyFilterSheet> createState() => _FamilyFilterSheetState();
}

class _FamilyFilterSheetState extends State<_FamilyFilterSheet> {
  late String? _village;
  late String? _relation;

  @override
  void initState() {
    super.initState();
    _village = widget.initialVillage;
    _relation = widget.initialRelation;
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
          _buildDropdown('Village / City', _village, widget.villageOptions, (v) => setState(() => _village = v)),
          const SizedBox(height: 12),
          _buildDropdown('Relation', _relation, widget.relationOptions, (v) => setState(() => _relation = v)),
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
                  onPressed: () => widget.onApply(_village, _relation),
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

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
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
              hint: const Text('Select', style: TextStyle(color: Colors.grey, fontSize: 14)),
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
