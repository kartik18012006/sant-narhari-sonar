import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/firestore_service.dart';
import 'matrimony_profile_detail_screen.dart';

/// List of grooms or brides from Firestore (after payment). Search + filter by City & Subcaste. Matches APK exactly.
class MatrimonyListScreen extends StatefulWidget {
  const MatrimonyListScreen({super.key, required this.isGroom});

  final bool isGroom;

  @override
  State<MatrimonyListScreen> createState() => _MatrimonyListScreenState();
}

class _MatrimonyListScreenState extends State<MatrimonyListScreen> {
  final _searchController = TextEditingController();
  String? _city;
  String? _subcaste;

  static const List<String> _cityOptions = ['Pune', 'Mumbai', 'Nagpur', 'Nashik', 'Kolhapur', 'Sangli', 'Other'];
  static List<String> get _subcasteOptions => AppTheme.subcasteOptions;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> list) {
    final type = widget.isGroom ? 'groom' : 'bride';
    var result = list.where((m) => (m['type'] as String? ?? '') == type).toList();
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((m) {
        final name = (m['name'] as String? ?? '').toLowerCase();
        final education = (m['education'] as String? ?? '').toLowerCase();
        final occupation = (m['occupation'] as String? ?? '').toLowerCase();
        final city = (m['city'] as String? ?? '').toLowerCase();
        return name.contains(query) ||
            education.contains(query) ||
            occupation.contains(query) ||
            city.contains(query);
      }).toList();
    }
    if (_city != null && _city!.isNotEmpty) {
      result = result.where((m) {
        final c = m['city'] as String? ?? '';
        return c == _city;
      }).toList();
    }
    if (_subcaste != null && _subcaste!.isNotEmpty) {
      result = result.where((m) {
        final sc = m['subcaste'] as String? ?? '';
        return sc == _subcaste;
      }).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isGroom ? 'Search Grooms / वर शोधा' : 'Search Brides / वधू शोधा';
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
                    hintText: widget.isGroom ? 'Search grooms by name, education...' : 'Search brides by name, education...',
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
                  label: 'City / शहर',
                  value: _city,
                  hint: 'Select city',
                  items: _cityOptions,
                  onChanged: (v) => setState(() => _city = v),
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
              stream: FirestoreService.instance.streamMatrimonyApproved(),
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
                          Icon(Icons.person_search, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            list.isEmpty
                                ? 'No ${widget.isGroom ? 'groom' : 'bride'} profiles yet.'
                                : 'No ${widget.isGroom ? 'groom' : 'bride'} profiles match your filters.',
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
                    final d = filtered[index];
                    final name = d['name'] as String? ?? '—';
                    final occupation = d['occupation'] as String? ?? '';
                    final education = d['education'] as String? ?? '';
                    final city = d['city'] as String? ?? '';
                    final photoUrl = d['photoUrl'] as String?;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: photoUrl != null && photoUrl.isNotEmpty
                              ? Image.network(
                                  photoUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _avatarFallback(name),
                                )
                              : _avatarFallback(name),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          [occupation, education, city].where((e) => e.isNotEmpty).join(' • '),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade500),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MatrimonyProfileDetailScreen(profile: d),
                            ),
                          );
                        },
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

  Widget _avatarFallback(String name) {
    return CircleAvatar(
      backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
      child: Text(
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
        style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
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
      builder: (ctx) => _MatrimonyFilterSheet(
        initialCity: _city,
        initialSubcaste: _subcaste,
        cityOptions: _cityOptions,
        subcasteOptions: _subcasteOptions,
        onClear: () {
          _clearFilters();
          Navigator.of(ctx).pop();
        },
        onApply: (city, subcaste) {
          setState(() {
            _city = city;
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

  void _clearFilters() {
    setState(() {
      _city = null;
      _subcaste = null;
      _searchController.clear();
    });
  }
}

class _MatrimonyFilterSheet extends StatefulWidget {
  const _MatrimonyFilterSheet({
    required this.initialCity,
    required this.initialSubcaste,
    required this.cityOptions,
    required this.subcasteOptions,
    required this.onClear,
    required this.onApply,
  });

  final String? initialCity;
  final String? initialSubcaste;
  final List<String> cityOptions;
  final List<String> subcasteOptions;
  final VoidCallback onClear;
  final void Function(String? city, String? subcaste) onApply;

  @override
  State<_MatrimonyFilterSheet> createState() => _MatrimonyFilterSheetState();
}

class _MatrimonyFilterSheetState extends State<_MatrimonyFilterSheet> {
  late String? _city;
  late String? _subcaste;

  @override
  void initState() {
    super.initState();
    _city = widget.initialCity;
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
          _buildDropdown('City / शहर', _city, widget.cityOptions, (v) => setState(() => _city = v)),
          const SizedBox(height: 12),
          _buildDropdown('Subcaste / पोटजात', _subcaste, widget.subcasteOptions, (v) => setState(() => _subcaste = v)),
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
                  onPressed: () => widget.onApply(_city, _subcaste),
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
              hint: Text('Select', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
